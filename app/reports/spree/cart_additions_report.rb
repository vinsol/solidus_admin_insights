module Spree
  class CartAdditionsReport < Spree::Report
    HEADERS = [:product_name, :additions, :quantity_change]
    DEFAULT_SORTABLE_ATTRIBUTE = :product_name

    attr_accessor :sortable_attribute, :sortable_type

    def initialize(options)
      super
      set_sortable_attributes(options)
    end

    def generate
      SpreeReportify::ReportDb[:spree_cart_events___cart_events].
      join(:spree_variants___variants, id: :variant_id).
      join(:spree_products___products, id: :product_id).
      where(cart_events__activity: 'add').
      where(cart_events__created_at: @start_date..@end_date).
      group(:product_name).
      order(sortable_sequel_expression)
    end

    def header_sorted?(header)
      sortable_attribute.eql?(header)
    end

    def set_sortable_attributes(options)
      self.sortable_type = (options[:sort] && options[:sort][:type].eql?('desc')) ? :desc : :asc
      self.sortable_attribute = options[:sort] ? options[:sort][:attribute].to_sym : DEFAULT_SORTABLE_ATTRIBUTE
    end

    def sortable_sequel_expression
      sortable_type.eql?(:desc) ? Sequel.desc(sortable_attribute) : Sequel.asc(sortable_attribute)
    end

    def select_columns(dataset)
      dataset.select{[
        :products__name___product_name,
        Sequel.as(count(:products__name), :additions),
        Sequel.as(sum(cart_events__quantity), :quantity_change)
      ]}
    end
  end
end
