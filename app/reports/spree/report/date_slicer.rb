module Spree::Report::DateSlicer
  def self.slice(start_date, end_date, zoom_level)
    case zoom_level
    when :hourly
      slice_into_hours(start_date, end_date)
    when :daily
      slice_into_days(start_date, end_date)
    when :monthly
      slice_into_months(start_date, end_date)
    when :yearly
      slice_into_years(start_date, end_date)
    end
  end

  def self.slice_into_hours(start_date, end_date)
    current_date = start_date
    slices = []
    while current_date <= end_date
      slices << (0..23).collect { |hour| { day: current_date.day, hour: hour } }
      current_date = current_date.next_day
    end
    slices.flatten
  end

  def self.slice_into_days(start_date, end_date)
    current_date = start_date
    slices = []
    while current_date <= end_date
      slices << { day: current_date.day, month: current_date.month }
      current_date = current_date.next_day
    end
    slices
  end

  def self.slice_into_months(start_date, end_date)
    current_date = start_date
    slices = []
    while current_date <= end_date
      slices << { year: current_date.year, month: current_date.month }
      current_date = current_date.end_of_month.next_day
    end
    slices
  end

  def self.slice_into_years(start_date, end_date)
    (start_date.year..end_date.year).collect { |year| { year: year } }
  end
end
