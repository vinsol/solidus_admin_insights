module Spree
  class ProductViewsToCartAdditionsReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :product_name
    HEADERS = { product_name: :string, views: :integer, cart_additions: :integer, cart_to_view_ratio: :string }
    SEARCH_ATTRIBUTES = { start_date: :product_view_from, end_date: :product_view_till }
    SORTABLE_ATTRIBUTES = [:product_name, :views, :cart_additions]

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
      cart_additions = SolidusAdminInsights::ReportDb[:spree_cart_events___cart_events].
      join(:spree_variants___variants, id: :variant_id).
      join(:spree_products___products, id: :product_id).
      where(cart_events__activity: 'add').
      where(cart_events__created_at: @start_date..@end_date). #filter by params
      group(:product_name).
      select{[
        (:products__name___product_name),
        (:products__slug___product_slug),
        Sequel.as(sum(cart_events__quantity), :cart_additions)
      ]}.as(:cart_additions)


      total_views_results = ::SolidusAdminInsights::ReportDb[:spree_products___products].
      join(:spree_page_events___page_events, target_id: :id).
      where(page_events__target_type: 'Spree::Product', page_events__activity: 'view').
      group(:product_name).
      select{[
        products__name.as(product_name),
        count('*').as(views)
      ]}

      ::SolidusAdminInsights::ReportDb[total_views_results].
      join(cart_additions, product_name: :product_name).
      order(sortable_sequel_expression)
    end

    def select_columns(dataset)
      dataset.select{[
        cart_additions__product_name,
        cart_additions__product_slug,
        views,
        cart_additions__cart_additions,
        Sequel.as(ROUND(cart_additions__cart_additions/ views, 2), :cart_to_view_ratio)
      ]}
    end
  end
end
