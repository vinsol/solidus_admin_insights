module Spree
  class CartAdditionsReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :product_name
    HEADERS = [:product_name, :sku, :additions, :quantity_change]
    SEARCH_ATTRIBUTES = { start_date: :product_added_from, end_date: :product_added_to }

    def initialize(options)
      super
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    def generate
      SpreeReportify::ReportDb[:spree_cart_events___cart_events].
      join(:spree_variants___variants, id: :variant_id).
      join(:spree_products___products, id: :product_id).
      where(cart_events__activity: 'add').
      where(cart_events__created_at: @start_date..@end_date).
      group(:variant_id).
      order(sortable_sequel_expression)
    end

    def select_columns(dataset)
      dataset.select{[
        :products__name___product_name,
        :variants__sku___sku,
        Sequel.as(count(:products__name), :additions),
        Sequel.as(sum(cart_events__quantity), :quantity_change)
      ]}
    end
  end
end
