module Spree
  class PaymentMethodTransactionsConversionRateReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :payment_method_name
    HEADERS = { payment_method_name: :string, payment_state: :string, months_name: :string, count: :integer }
    SEARCH_ATTRIBUTES = { start_date: :payments_created_from, end_date: :payments_created_to }
    SORTABLE_ATTRIBUTES = [:payment_method_name, :successful_payments_count, :failed_payments_count, :pending_payments_count, :invalid_payments_count]

    def paginated?
      false
    end

    class Result < Spree::Report::TimedResult
      charts PaymentMethodStateDistributionChart

      def build_empty_observations
        @_payment_methods = @results.collect { |result| result['payment_method_name'] }.uniq
        super
        @observations = @_payment_methods.collect do |payment_method_name|
          @observations.collect do |observation|
            _d_observation = observation.dup
            _d_observation.payment_method_name =  payment_method_name
            _d_observation.count = 0
            _d_observation
          end
        end.flatten
      end

      class Observation < Spree::Report::TimedObservation
        observation_fields [:payment_method_name, :payment_state, :count]

        def payment_state
          if @payment_state == 'pending'
            'pending'
          else
            "capturing #{ @payment_state }"
          end
        end

        def describes?(result, zoom_level)
          (result['payment_method_name'] == payment_method_name) && super
        end
      end
    end

    def report_query
      payment_methods =
        Spree::PaymentMethod
          .joins(:payments)
          .where(spree_payments: { created_at: @start_date..@end_date })
          .select(
            'spree_payment_methods.id as payment_method_id',
            'name as payment_method_name',
            'state as payment_state',
            *zoom_selects('spree_payments')
          )

      grouped =
        Spree::Report::QueryFragments
          .from_subquery(payment_methods)
          .group(*zoom_columns_to_s, 'payment_method_name', 'payment_state')
          .order(*zoom_columns)
          .project(
            *zoom_columns,
            'payment_method_name',
            'payment_state',
            'COUNT(payment_method_id) as count'
          )
    end
  end
end
