module Spree
  class Report
    module Chart
      extend ActiveSupport::Concern

      def chart_json
        self.class::Chart.new(self, time_dimension).to_h
      end
    end
  end
end
