module Spree::Report::QueryZoom
  def self.select(zoom_level, zoom_on)
    db_col_name = zoom_on.present? ? "#{ zoom_on }.created_at" : "created_at"
    zoom_columns(zoom_level).collect { |zoom_column| ::Spree::Report::QueryFragments.public_send(zoom_column, db_col_name) }
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
