module Spree
  class PaymentMethodTransactionsConversionRateReport < Spree::Report
    HEADERS = [:payment_method_name, :successful_payments_count, :failed_payments_count]

    def generate
      SpreeReportify::ReportDb[:spree_payment_methods___payment_methods].
      join(:spree_payments___payments, payment_method_id: :id).
      where(payments__created_at: @start_date..@end_date). #filter by params
      group(:payment_method_name)
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
