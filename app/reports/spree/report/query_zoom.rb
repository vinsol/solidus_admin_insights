module Spree::Report::QueryZoom
  def self.select(zoom_level)
    zoom_columns(zoom_level).collect { |zoom_column| ::Spree::Report::QueryFragments.public_send(zoom_column, :created_at) }
  end

  def self.zoom_columns(zoom_level)
    case zoom_level
    when :hourly
      [:day, :hour]
    when :daily
      [:month, :day]
    when :monthly
      [:year, :month]
    when :yearly
      [:year]
    end
  end
end
