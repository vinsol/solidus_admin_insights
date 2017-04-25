module Spree
  class Report

    attr_accessor :sortable_attribute, :sortable_type

    ZOOM_LEVELS = [:hourly, :daily, :monthly, :yearly]

    def paginated?
      true
    end

    def no_pagination?
      !paginated?
    end

    def arel?
      false
    end

    def deeplink_properties
      {
        deeplinked: false,
        base_url: ''
      }
    end

    def generate(options = {})
      self.class::Result.new(report_query) do |report|
        report.start_date = @start_date
        report.end_date   = @end_date
        report.zoom_level = @zoom_level
        report.report_klass = self.class
      end.to_a
    end

    def initialize(options)
      @search = options.fetch(:search, {})
      extract_reporting_period
      determine_report_zoom
    end

    def header_sorted?(header)
      sortable_attribute.eql?(header)
    end

    class ReportQueryNotImplemented < StandardError
    end

    def report_query
      raise ReportQueryNotImplemented
    end

    def set_sortable_attributes(options, default_sortable_attribute)
      self.sortable_type ||= (options[:sort] && options[:sort][:type].eql?('desc')) ? :desc : :asc
      self.sortable_attribute = options[:sort] ? options[:sort][:attribute].to_sym : default_sortable_attribute
    end

    def sortable_sequel_expression
      sortable_type.eql?(:desc) ? Sequel.desc(sortable_attribute) : Sequel.asc(sortable_attribute)
    end

    def chart_json
      { chart: false, charts: [] }
    end

    def zoom_selects
      @_zoom_selects ||= QueryZoom.select(@zoom_level)
    end

    def zoom_columns
      @_zoom_columns ||= QueryZoom.zoom_columns(@zoom_level)
    end

    def zoom_columns_to_s
      @_zoom_columns_to_s ||= zoom_columns.collect(&:to_s)
    end

    private def extract_reporting_period
      start_date = @search[:start_date]
      @start_date = start_date.present? ? Date.parse(start_date) :  Date.new(Date.current.year)
      end_date = @search[:end_date]
      @end_date = (end_date.present? ? Date.parse(end_date).next_day  : Date.current.end_of_year)
    end

    private def determine_report_zoom
      @zoom_level =
        case (@end_date - @start_date).to_i
        when 0..1
          :hourly
        when 1..60
          :daily
        when 61..600
          :monthly
        else
          :yearly
        end
    end
  end
end
