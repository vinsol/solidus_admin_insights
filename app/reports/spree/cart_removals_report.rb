module Spree
  class CartRemovalsReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :product_name
    HEADERS = { sku: :string, product_name: :string, removals: :integer, quantity_change: :integer }
    SEARCH_ATTRIBUTES = { start_date: :product_added_from, end_date: :product_added_to }
    SORTABLE_ATTRIBUTES = [:product_name, :sku, :removals, :quantity_change]

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
        observation_fields [:product_name, :product_slug, :removals, :quantity_change, :sku]

        def sku
          @sku || @product_name
        end
      end

    end

    def report_query
      Spree::CartEvent
        .removed
        .joins(:variant)
        .joins(:product)
        .where(created_at: @start_date..@end_date)
        .group('product_name', 'product_slug', 'spree_variants.sku')
        .select(
          'spree_products.name as product_name',
          'spree_products.slug as product_slug',
          'spree_variants.sku as sku',
          'count(spree_products.name) as removals',
          'sum(spree_cart_events.quantity) as quantity_change'
        )
    end
  end
end
