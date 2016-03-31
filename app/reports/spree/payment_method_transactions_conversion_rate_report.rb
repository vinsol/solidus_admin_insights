module Spree
  class PaymentMethodTransactionsConversionRateReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :payment_method_name
    HEADERS = [:payment_method_name, :successful_payments_count, :failed_payments_count]
    SEARCH_ATTRIBUTES = { start_date: :payments_created_from, end_date: :payments_created_to }

    def initialize(options)
      super
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    def generate
      SpreeReportify::ReportDb[:spree_payment_methods___payment_methods].
      join(:spree_payments___payments, payment_method_id: :id).
      where(payments__created_at: @start_date..@end_date). #filter by params
      group(:payment_method_name).
      order(sortable_sequel_expression)
    end

    def select_columns(dataset)
      dataset.select{[
        :payment_methods__name___payment_method_name,
        Sequel.as(sum(IF(payments__state = 'completed', 1, 0)), :successful_payments_count),
        Sequel.as(sum(IF(payments__state = 'failure', 1, 0)), :failed_payments_count)
      ]}
    end
  end
end
