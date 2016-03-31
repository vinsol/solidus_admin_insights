module Spree
  class Report

    attr_accessor :sortable_attribute, :sortable_type

    def generate(options = {})
      raise 'Please define this method in inherited class'
    end

    def initialize(options)
      @search = options.fetch(:search, {})
      start_date = @search[:start_date]
      @start_date = start_date.present? ? Date.parse(start_date) :  Date.new(Date.current.year)

      end_date = @search[:end_date]
      # 1.day is added to date so that we can get current date records
      # since date consider time at midnight
      @end_date = (end_date.present? ? Date.parse(end_date) : Date.current) + 1.day
    end

    def header_sorted?(header)
      sortable_attribute.eql?(header)
    end

    def set_sortable_attributes(options, default_sortable_attribute)
      self.sortable_type = (options[:sort] && options[:sort][:type].eql?('desc')) ? :desc : :asc
      self.sortable_attribute = options[:sort] ? options[:sort][:attribute].to_sym : default_sortable_attribute
    end

    def sortable_sequel_expression
      sortable_type.eql?(:desc) ? Sequel.desc(sortable_attribute) : Sequel.asc(sortable_attribute)
    end

  end
end
