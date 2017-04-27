module Spree
  class PaymentMethodTransactionsReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :payment_method_name
    HEADERS = { payment_method_name: :string, payment_amount: :integer }
    SEARCH_ATTRIBUTES = { start_date: :payments_created_from, end_date: :payments_created_till }
    SORTABLE_ATTRIBUTES = []

    def initialize(options)
      super
      @zoom_on = 'spree_payments'
    end

    def paginated?
      false
    end

    class Result < Spree::Report::TimedResult
      charts PaymentMethodRevenueDistributionChart

      def build_empty_observations
        @_payment_methods = @results.collect { |result| result['payment_method_name'] }.uniq
        super
        @observations = @_payment_methods.collect do |payment_method_name|
          @observations.collect do |observation|
            _d_observation = observation.dup
            _d_observation.payment_amount = 0
            _d_observation.payment_method_name = payment_method_name
            _d_observation
          end
        end.flatten
      end

      class Observation < Spree::Report::TimedObservation
        observation_fields [:payment_method_name, :payment_amount]

        def describes?(result, zoom_level)
          (result['payment_method_name'] == payment_method_name) && super
        end

        def payment_amount
          @payment_amount.to_f
        end

      end
    end

    def report_query
      payments =
        Spree::PaymentMethod
          .joins(:payments)
          .where(spree_payments: { created_at: @start_date..@end_date })
          .select(
            'spree_payment_methods.name as payment_method_name',
            'spree_payments.amount as payment_amount',
            *zoom_selects(@zoom_on)
          )

      Spree::Report::QueryFragments
        .from_subquery(payments)
        .group(*zoom_columns_to_s, 'payment_method_name')
        .order(*zoom_columns)
        .project(
          *zoom_columns,
          'payment_method_name',
          'SUM(payment_amount) as payment_amount'
        )
    end

  end
end
