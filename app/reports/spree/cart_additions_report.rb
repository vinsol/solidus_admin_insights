module Spree
  class CartAdditionsReport < Spree::Report
    HEADERS = [:product_name, :additions, :quantity_change]

    def self.generate(options = {})
      assign_search_params(options)
      SpreeReportify::ReportDb[:spree_cart_events___cart_events].
      join(:spree_variants___variants, id: :variant_id).
      join(:spree_products___products, id: :product_id).
      where(cart_events__activity: 'add').
      where(cart_events__created_at: @start_date..@end_date). #filter by params
      group(:product_name)
    end

    def self.select_columns(dataset)
      dataset.select{[
        :products__name___product_name,
        Sequel.as(count(:products__name), :additions),
        Sequel.as(sum(cart_events__quantity), :quantity_change)
      ]}
    end
  end
end
