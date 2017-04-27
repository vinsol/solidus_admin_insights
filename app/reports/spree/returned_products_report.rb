module Spree
  class ReturnedProductsReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :product_name
    HEADERS = { sku: :string, product_name: :string, return_count: :integer }
    SEARCH_ATTRIBUTES = { start_date: :product_returned_from, end_date: :product_returned_till }
    SORTABLE_ATTRIBUTES = [:product_name, :sku, :return_count]

    def initialize(options)
      super
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    class Result < Spree::Report::Result
      class Observation < Spree::Report::Observation
        observation_fields [:sku, :product_name, :return_count]

        def sku
          @sku || @product_name
        end
      end
    end

    def paginated?
      false
    end

    def report_query
      Spree::ReturnAuthorization
        .joins(:return_items)
        .joins(:inventory_units)
        .joins(:variants)
        .joins(:products)
        .where(spree_return_items: { created_at: @start_date..@end_date })
        .group('spree_variants.id', 'spree_products.name', 'spree_products.slug', 'spree_variants.sku')
        .select(
          'spree_products.name as product_name',
          'spree_products.slug as product_slug',
          'spree_variants.sku as sku',
          'COUNT(spree_variants.id) as return_count'
        )
    end

    def deeplink_properties
      {
        deeplinked: true,
        product_name: { template: %Q{<a href="/admin/products/{%# o.product_slug %}" target="_blank">{%# o.product_name %}</a>} }
      }
    end

  end
end
