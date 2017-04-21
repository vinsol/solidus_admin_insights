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

    def generate
      SolidusAdminInsights::ReportDb[:spree_return_authorizations].
      join(:spree_return_items, return_authorization_id: :spree_return_authorizations__id).
      join(:spree_inventory_units, spree_inventory_units__id: :inventory_unit_id).
      join(:spree_variants, spree_variants__id: :variant_id).
      join(:spree_products, id: :product_id).
      where(spree_return_items__created_at: @start_date..@end_date).
      group(:variant_id).
      order(sortable_sequel_expression)
    end

    def deeplink_properties
      {
        deeplinked: true,
        product_name: { template: %Q{<a href="/admin/products/{%# o.product_slug %}" target="_blank">{%# o.product_name %}</a>} }
      }
    end

    def select_columns(dataset)
      dataset.select{[
        spree_products__name.as(product_name),
        spree_products__slug.as(product_slug),
        Sequel.as(IF(STRCMP(spree_variants__sku, ''), spree_variants__sku, spree_products__name), :sku),
        Sequel.as(count(:variant_id), :return_count)
      ]}
    end
  end
end
