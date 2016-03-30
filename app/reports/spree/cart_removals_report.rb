module Spree
  class CartRemovalsReport < Spree::Report
    HEADERS = [:product_name, :removals, :quantity_change]

    def generate
      SpreeReportify::ReportDb[:spree_cart_events___cart_events].
      join(:spree_variants___variants, id: :variant_id).
      join(:spree_products___products, id: :product_id).
      where(cart_events__activity: 'remove').
      where(cart_events__created_at: @start_date..@end_date). #filter by params
      group(:product_name)
    end

    def select_columns(dataset)
      dataset.select{[
        :products__name___product_name,
        Sequel.as(count(:products__name), :removals),
        Sequel.as(sum(cart_events__quantity), :quantity_change)
      ]}
    end
  end
end
