module Spree
  class PromotionalCostReport < Spree::Report
    HEADERS = [:promotion_name, :usage_count, :promotion_discount]
    DEFAULT_SORTABLE_ATTRIBUTE = :promotion_name

    def initialize(options)
      super
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    def generate(options = {})
      SpreeReportify::ReportDb[:spree_adjustments___adjustments].
      join(:spree_promotion_actions___promotion_actions, id: :source_id).
      join(:spree_promotions___promotions, id: :promotion_id).
      where(adjustments__source_type: "Spree::PromotionAction").
      where(promotions__created_at: @start_date..@end_date). #filter by params
      group(:promotions__id).
      order(sortable_sequel_expression)
    end

    def select_columns(dataset)
      dataset.select{[
        Sequel.as(abs(sum(:amount)), :promotion_discount),
        Sequel.as(count(:promotions__id), :usage_count),
        :promotions__name___promotion_name
      ]}
    end
  end
end
