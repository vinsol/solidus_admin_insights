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

    def paginated?
      false
    end

    class Result < Spree::Report::Result
      class Observation < Spree::Report::Observation
        observation_fields [:product_name, :product_slug, :views, :cart_additions, :cart_to_view_ratio]
      end
    end

    def get_results
      ActiveRecord::Base.connection.execute(report_query.to_sql).to_a
    end

    def report_query
      cart_additions =
        Spree::CartEvent
          .added
          .joins(:variant)
          .joins(:product)
          .where(created_at: @start_date..@end_date)
          .group('spree_products.name', 'spree_products.slug')
          .select(
            'spree_products.name as product_name',
            'spree_products.slug as product_slug',
            'SUM(spree_cart_events.quantity) as cart_additions'
          )
      total_views =
        Spree::Product
          .joins(:page_view_events)
          .group(:name)
          .select(
            'spree_products.name as product_name',
            'COUNT(*) as views'
          )

      Spree::Report::QueryFragments
        .from_join(cart_additions, total_views, "q1.product_name = q2.product_name")
        .project(
          'q1.product_name',
          'q1.product_slug',
          'q2.views',
          'q1.cart_additions',
          'ROUND(cart_additions/views, 2) as cart_to_view_ratio'
        )
    end

  end
end
