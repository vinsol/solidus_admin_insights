module Spree
  class Report
    def self.generate(options = {})
      raise 'Please define this method in inherited class'
    end

    def self.assign_search_params(options)
      @search = options.fetch(:search, {})
      start_date = @search[:start_date]
      @start_date = start_date.present? ? Date.parse(start_date) : Date.new

      end_date = @search[:end_date]
      @end_date = (end_date.present? ? Date.parse(end_date) : Date.today) + 1.day
    end
  end
end
