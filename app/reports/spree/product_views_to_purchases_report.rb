module Spree
  class ProductViewsToPurchasesReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :product_name
    HEADERS = { product_name: :string, views: :integer, purchases: :integer, purchase_to_view_ratio: :integer }
    SEARCH_ATTRIBUTES = { start_date: :product_view_from, end_date: :product_view_till }
    SORTABLE_ATTRIBUTES = [:product_name, :views, :purchases]

    def initialize(options)
      super
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    def deeplink_properties
      {
        deeplinked: true,
        product_name: { template: %Q{<a href="/admin/products/{%# o.product_slug %}" target="_blank">{%# o.product_name %}</a>} }
      }
    end

    def generate(options = {})
      line_items = ::SolidusAdminInsights::ReportDb[:spree_line_items___line_items].
      join(:spree_orders___orders, id: :order_id).
      join(:spree_variants___variants, variants__id: :line_items__variant_id).
      join(:spree_products___products, products__id: :variants__product_id).
      where(orders__state: 'complete').
      where(orders__created_at: @start_date..@end_date). #filter by params
      select{[
      sum(quantity).as(purchases),
      products__name.as(product_name),
      products__slug.as(product_slug),
      products__id.as(product_id)]}.
      group(:products__name, :products__id).as(:line_items)


      ::SolidusAdminInsights::ReportDb[line_items].join(:spree_page_events___page_events, page_events__target_id: :product_id).
        where(page_events__target_type: 'Spree::Product', page_events__activity: 'view').
        group(:product_id).
        order(sortable_sequel_expression)
    end

    def select_columns(dataset)
      dataset.select{[
        product_name,
        product_slug,
        count('*').as(views),
        purchases,
        Sequel.as(ROUND(purchases / count('*'), 2), :purchase_to_view_ratio)
      ]}
    end
  end
end
