module Spree
  class Report
    class Result
      attr_accessor :start_date, :end_date, :zoom_level, :report_klass

      def initialize(query)
        yield self
        build_report_from_query(query)
      end

      def fill_report_slices
        result_iter = @results.each
        current_result = result_iter.next
        @report_slices.collect do |report_slice|
          if current_result && (current_result.fetch_values(*@report_keys) == report_slice.fetch_values(*@report_keys))
            report_slice.merge!(current_result)
            begin
              current_result = result_iter.next
            rescue StopIteration
              current_result = nil
            end
          else
            report_slice.merge!(empty_slice)
          end
        end
      end

      def build_report_from_query(query)
        populate_results(query)
        build_empty_slices
        fill_report_slices
        humanize_report_data
      end

      def build_empty_slices
        @report_slices = Spree::Report::DateSlicer.slice(start_date, end_date, zoom_level)
        @report_keys = @report_slices.first.keys
      end

      def populate_results(query)
        @results = ActiveRecord::Base.connection.execute(query.to_sql).collect(&:symbolize_keys)
      end

      class EmptySliceUndefinedError < StandardError
      end

      def empty_slice
        raise EmptySliceUndefinedError
      end

      def user_db_results_as_reports
        @report_slices = @results
      end

      def humanize_report_data
        # Implement to prettify report results where applicable
        add_month_name_to_reports if @zoom_level.in?([:monthly, :daily])
      end

      def add_month_name_to_reports
        # Assumes month key is present
        @report_slices.each { |report_slice| report_slice[:months_name] = Date::MONTHNAMES[report_slice[:month]] }
      end

      def to_a
        @report_slices
      end
    end

  end
end
