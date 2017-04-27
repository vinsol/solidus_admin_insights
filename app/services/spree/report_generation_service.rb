module Spree
  class ReportGenerationService

    REPORTS = DEFAULT_ADMIN_INSIGHT_REPORTS

    def self.generate_report(report_name, options)
      klass = Spree.const_get((report_name.to_s + '_report').classify)
      resource = klass.new(options)
      dataset = resource.generate
    end

    def self.download(report, options = {})
      headers = report.headers
      stats = report.observations
      ::CSV.generate(options) do |csv|
        csv << headers.map { |head| head[:name] }
        stats.each do |record|
          csv << headers.map { |head| record.public_send(head[:value]) }
        end
      end
    end

    def self.report_exists?(type, name)
      REPORTS.key?(type) && REPORTS[type].include?(name)
    end

    def self.reports_for_type(type)
      REPORTS[type]
    end

    def self.default_report_type
      REPORTS.keys.first
    end

    def self.register_report_category(category)
      REPORTS[category] = []
    end

    def self.register_report(category, report_name)
      REPORTS[category] << report_name
    end

  end
end
