module Spree
  class UniquePurchasesReport < Spree::Report
    HEADERS = [:product_name, :sold_count, :users]
    DEFAULT_SORTABLE_ATTRIBUTE = :product_name

    def initialize(options)
      super
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    def generate(options = {})
      ::SpreeReportify::ReportDb[:spree_line_items___line_items].
      join(:spree_orders___orders, id: :order_id).
      join(:spree_variants___variants, variants__id: :line_items__variant_id).
      join(:spree_products___products, products__id: :variants__product_id).
      where(orders__state: 'complete').
      where(orders__completed_at: @start_date..@end_date). #filter by params
      group(:products__name).
      order(sortable_sequel_expression)
    end

    def select_columns(dataset)
      dataset.select{[
        products__name.as(product_name),
        sum(quantity).as(sold_count),
        (count(distinct orders__user_id) + count(orders__id) - count(orders__user_id)).as(users)
      ]}
    end
  end
end
