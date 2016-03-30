module Spree
  class BestSellingProductsReport < Spree::Report
    HEADERS = [:product_name, :sold_count]

    def initialize(options)
      super
      @name = @search[:name].present? ? "%#{ @search[:name] }%" : '%'
    end

    def generate
      ::SpreeReportify::ReportDb[:spree_line_items___line_items].
      join(:spree_orders___orders, id: :order_id).
      join(:spree_variants___variants, variants__id: :line_items__variant_id).
      join(:spree_products___products, products__id: :variants__product_id).
      where(orders__state: 'complete').
      where(orders__completed_at: @start_date..@end_date). #filter by params
      group(:products__name)
    end

    def select_columns(dataset)
      dataset.select{[
        products__name.as(product_name),
        sum(quantity).as(sold_count)
      ]}
    end
  end
end
