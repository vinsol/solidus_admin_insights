module Spree
  class Report
    class Result
      attr_accessor :start_date, :end_date, :zoom_level, :report
      attr_reader   :observations

      def initialize
        yield self
        build_report_observations
      end

      def build_report_observations
        query_results
        populate_observations
      end

      def query_results
        @results = report.get_results
      end

      def populate_observations
        @observations = @results.collect do |result|
          _observation = self.class::Observation.new
          _observation.populate(result)
          _observation
        end
      end


      def to_h
        {
          deeplink:            report.deeplink_properties,
          total_pages:         report.total_pages,
          per_page:            report.records_per_page,
          pagination_required: report.paginated?,
          headers:             headers,
          search_attributes:   search_attributes,
          stats:               observations.collect(&:to_h),
          chart_json:          chart_json
        }
      end

      def chart_json
        {
          chart: false,
          charts: []
        }
      end

      def self.charts(*report_charts)
        define_method :chart_json do
          {
            chart: true,
            charts: report_charts.collect { |report_chart| report_chart.new(self).to_h }.flatten
          }
        end
      end

      def search_attributes
        report.class::SEARCH_ATTRIBUTES.transform_values { |value| value.to_s.humanize }
      end

      def total_pages # O indexed
        if report.paginated?
          total_pages = report.total_records / report.records_per_page
          if report.total_records % report.records_per_page == 0
            total_pages -= 1
          end
          total_pages
        end
      end

      def headers
        report.class::HEADERS.keys.collect do |header|
          {
            name: Spree.t(header.to_sym, scope: [:insight, report.name]),
            value: header,
            type: report.class::HEADERS[header],
            sortable: header.in?(report.class::SORTABLE_ATTRIBUTES)
          }
        end
      end

      def time_dimension
        case zoom_level
        when :hourly
          :hour_name
        when :daily
          :day_name
        when :monthly
          :month_name
        when :yearly
          :year
        end
      end
    end
  end
end
