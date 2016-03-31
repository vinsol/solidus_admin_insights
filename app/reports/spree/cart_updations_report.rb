module Spree
  class CartUpdationsReport < Spree::Report
    HEADERS = [:product_name, :updations, :quantity_increase, :quantity_decrease]
    DEFAULT_SORTABLE_ATTRIBUTE = :product_name

    def initialize(options)
      super
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    def generate
      SpreeReportify::ReportDb[:spree_cart_events___cart_events].
      join(:spree_variants___variants, id: :variant_id).
      join(:spree_products___products, id: :product_id).
      where(activity: 'update').
      where(cart_events__created_at: @start_date..@end_date). #filter by params
      group(:product_name)
      order(sortable_sequel_expression)
    end

    def select_columns(dataset)
      dataset.select{[
        :products__name___product_name,
        Sequel.as(count(:products__name), :updations),
        Sequel.as(sum(IF(cart_events__quantity >= 0, cart_events__quantity, 0)), :quantity_increase),
        Sequel.as(sum(IF(cart_events__quantity <= 0, cart_events__quantity, 0)), :quantity_decrease)
      ]}
    end
  end
end
