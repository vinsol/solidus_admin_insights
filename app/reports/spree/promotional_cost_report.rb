module Spree
  class PromotionalCostReport < Spree::Report
    HEADERS = [:promotion_name, :usage_count, :promotion_discount]

    def self.generate(options = {})
      SpreeReportify::ReportDb[:spree_adjustments___adjustments].
      join(:spree_promotion_actions___promotion_actions, id: :source_id).
      join(:spree_promotions___promotions, id: :promotion_id).
      where(adjustments__source_type: "Spree::PromotionAction").
      group(:promotions__id).
      select{[
        Sequel.as(abs(sum(:amount)), :promotion_discount),
        Sequel.as(count(:promotions__id), :usage_count),
        :promotions__name___promotion_name
      ]}
    end
  end
end
