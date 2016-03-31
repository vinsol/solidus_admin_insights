module Spree
  class PaymentMethodTransactionsReport < Spree::Report
    HEADERS = [:payment_method_name, :payment_count]
    SEARCH_ATTRIBUTES = { start_date: :payments_created_from, end_date: :payments_created_till }

    def self.generate(options = {})
      assign_search_params(options)
      SpreeReportify::ReportDb[:spree_payment_methods___payment_methods].
      join(:spree_payments___payments, payment_method_id: :id).
      where(payments__created_at: @start_date..@end_date). #filter by params
      group(:payment_method_name)
    end

    def self.select_columns(dataset)
      dataset.select{[
        :payment_methods__name___payment_method_name,
        count(payments__payment_method_id).as(:payment_count)
      ]}
    end
  end
end
