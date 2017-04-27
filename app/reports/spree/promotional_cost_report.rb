module Spree
  class PromotionalCostReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :promotion_name
    HEADERS = { promotion_name: :string, usage_count: :integer, promotion_discount: :integer, promotion_code: :string, promotion_start_date: :date, promotion_end_date: :date }
    SEARCH_ATTRIBUTES = { start_date: :promotion_created_from, end_date: :promotion_created_till }
    SORTABLE_ATTRIBUTES = [:promotion_name, :usage_count, :promotion_discount, :promotion_code, :promotion_start_date, :promotion_end_date]

    def paginated?
      false
    end

    def initialize(options)
      super
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
      @zoom_on = 'spree_adjustments'
    end

    class Result < Spree::Report::TimedResult
      charts PromotionalCostChart, UsageCountChart

      def build_empty_observations
        @_promotions = @results.collect { |result| result['promotion_name'] }.uniq
        super
        @observations = @_promotions.collect do |promotion_name|
          @observations.collect do |observation|
            _d_observation = observation.dup
            _d_observation.promotion_name = promotion_name
            _d_observation.usage_count = 0
            _d_observation
          end
        end.flatten
      end

      class Observation < Spree::Report::TimedObservation
        observation_fields [
          :promotion_name, :usage_count,
          :promotion_discount, :promotion_code,
          :promotion_start_date, :promotion_end_date
        ]

        def promotion_start_date
          @promotion_start_date.present? ? @promotion_start_date.to_date.strftime("%B %d %Y") : "-"
        end

        def promotion_end_date
          @promotion_end_date.present? ? @promotion_end_date.to_date.strftime("%B %d %Y") : "-"
        end

        def promotion_discount
          @promotion_discount.to_f.abs
        end

        def describes?(result, zoom_level)
          result['promotion_name'] == promotion_name && super
        end
      end
    end

    def report_query
      eligible_promotions =
        Spree::PromotionAction
          .joins(:promotion)
          .joins(:adjustment)
          .where(spree_adjustments: { created_at: @start_date..@end_date })
          .select(
            'spree_promotions.starts_at as promotion_start_date',
            'spree_promotions.expires_at as promotion_end_date',
            'spree_adjustments.amount as promotion_discount',
            'spree_promotions.id as promotion_id',
            'spree_promotions.name as promotion_name',
            'spree_promotions.code as promotion_code',
            *zoom_selects('spree_adjustments')
          )

      grouped_usage =
        Spree::Report::QueryFragments
          .from_subquery(eligible_promotions)
          .group(*zoom_columns, :promotion_id, :promotion_name, :promotion_code, :promotion_start_date, :promotion_end_date)
          .order(*zoom_columns_to_s)
          .project(
            *zoom_columns,
            'promotion_name',
            'promotion_code',
            'promotion_start_date',
            'promotion_end_date',
            'SUM(promotion_discount) as promotion_discount',
            'COUNT(promotion_id) as usage_count',
            'promotion_id'
          )
    end

  end
end
