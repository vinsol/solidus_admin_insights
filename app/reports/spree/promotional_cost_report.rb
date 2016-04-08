module Spree
  class PromotionalCostReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :promotion_name
    HEADERS = { promotion_name: :string, usage_count: :integer, promotion_discount: :integer, promotion_code: :string, promotion_start_date: :date, promotion_end_date: :date }
    SEARCH_ATTRIBUTES = { start_date: :promotion_created_from, end_date: :promotion_created_till }
    SORTABLE_ATTRIBUTES = [:promotion_name, :usage_count, :promotion_discount, :promotion_code, :promotion_start_date, :promotion_end_date]

    def initialize(options)
      super
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    def generate(options = {})
      initialize_months_table
      # Spree::Promotion.pluck(:id)
      _id = 1
      (adjustments_with_month_name = SpreeReportify::ReportDb[:spree_adjustments___adjustments].
          join(:spree_promotion_actions___promotion_actions, id: :source_id).
          join(:spree_promotions___promotions, id: :promotion_id).
          where(adjustments__source_type: "Spree::PromotionAction", promotions__id: _id).
          # where(promotions__created_at: @start_date..@end_date). #filter by params
          select{[
            Sequel.as(abs(:amount), :promotion_discount),
            Sequel.as(:promotions__id, :promotions_id),
            :promotions__name___promotion_name,
            Sequel.as(MONTHNAME(:adjustments__created_at), :month_name),
            Sequel.as(YEAR(:adjustments__created_at), :year)
          ]}

          SpreeReportify::ReportDb[adjustments_with_month_name].
          right_outer_join(:months, name: :month_name).
          group(:months_name, :promotions_id).
          # order(:promotions_id, :sort_year, :number).
          order(:sort_year, :number).
          select{[
            months__number,
            Sequel.as(IFNULL(year, 2016), :sort_year),
            Sequel.as(concat(name, ' ', IFNULL(year, 2016)), :months_name),
            Sequel.as(IFNULL(SUM(promotion_discount), 0), :promotion_discount),
            Sequel.as(IFNULL(promotion_name, ''), :promotion_name),
            Sequel.as(count(:promotions_id), :usage_count),
            Sequel.as(IFNULL(promotions_id, _id), :promotions_id)
          ]}).union(
          (adjustments_with_month_name = SpreeReportify::ReportDb[:spree_adjustments___adjustments].
          join(:spree_promotion_actions___promotion_actions, id: :source_id).
          join(:spree_promotions___promotions, id: :promotion_id).
          where(adjustments__source_type: "Spree::PromotionAction", promotions__id: _id).
          # where(promotions__created_at: @start_date..@end_date). #filter by params
          select{[
            Sequel.as(abs(:amount), :promotion_discount),
            Sequel.as(:promotions__id, :promotions_id),
            :promotions__name___promotion_name,
            Sequel.as(MONTHNAME(:adjustments__created_at), :month_name),
            Sequel.as(YEAR(:adjustments__created_at), :year)
          ]}

          SpreeReportify::ReportDb[adjustments_with_month_name].
          right_outer_join(:months, name: :month_name).
          group(:months_name, :promotions_id).
          # order(:promotions_id, :sort_year, :number).
          order(:sort_year, :number).
          select{[
            months__number,
            Sequel.as(IFNULL(year, 2016), :sort_year),
            Sequel.as(concat(name, ' ', IFNULL(year, 2016)), :months_name),
            Sequel.as(IFNULL(SUM(promotion_discount), 0), :promotion_discount),
            Sequel.as(IFNULL(promotion_name, ''), :promotion_name),
            Sequel.as(count(:promotions_id), :usage_count),
            Sequel.as(IFNULL(promotions_id, _id), :promotions_id)
          ]})
        )
      end
    end

    def chart_data
    end

    def select_columns(dataset)
      dataset
    end
  end
end
