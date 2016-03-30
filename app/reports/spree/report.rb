module Spree
  class Report
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
  end
end
