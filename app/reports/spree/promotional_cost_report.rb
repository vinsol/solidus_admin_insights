module Spree
  class PromotionalCostReport < Spree::Report
    HEADERS = [:promotion_name, :usage_count, :promotion_discount]

    def self.generate(options = {})
      assign_search_params(options)
      SpreeReportify::ReportDb[:spree_adjustments___adjustments].
      join(:spree_promotion_actions___promotion_actions, id: :source_id).
      join(:spree_promotions___promotions, id: :promotion_id).
      where(adjustments__source_type: "Spree::PromotionAction").
      where(promotions__created_at: @start_date..@end_date). #filter by params
      group(:promotions__id)
    end

    def self.select_columns(dataset)
      dataset.select{[
        Sequel.as(abs(sum(:amount)), :promotion_discount),
        Sequel.as(count(:promotions__id), :usage_count),
        :promotions__name___promotion_name
      ]}
    end
  end
end
