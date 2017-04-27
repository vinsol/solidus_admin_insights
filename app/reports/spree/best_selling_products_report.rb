module Spree
  class BestSellingProductsReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :sold_count
    HEADERS = { sku: :string, product_name: :string, sold_count: :integer }
    SEARCH_ATTRIBUTES = { start_date: :orders_completed_from, end_date: :orders_completed_to }
    SORTABLE_ATTRIBUTES = [:product_name, :sku, :sold_count]

    def initialize(options)
      super
      @name = @search[:name].present? ? "%#{ @search[:name] }%" : '%'
      @sortable_type = :desc if options[:sort].blank?
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
        observation_fields [:product_name, :product_slug, :sku, :sold_count]

        def sku
          @sku || @product_name
        end
      end
    end

    def report_query
      data_query =
        Spree::LineItem
          .joins(:order)
          .joins(:variant)
          .joins(:product)
          .where(spree_orders: { state: 'complete' })
          .where(spree_orders: { completed_at: @start_date..@end_date })
          .group(:variant_id, :product_name, :product_slug, 'spree_variants.sku')
          .select(
            'spree_products.name as product_name',
            'spree_products.slug as product_slug',
            'spree_variants.sku  as sku',
            'sum(quantity) as sold_count'
          ).order('sold_count DESC')
    end

  end
end
