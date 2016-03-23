module Spree
  class PaymentMethodTransactionsReport < Spree::Report
    HEADERS = [:payment_method_name, :payment_count]

    def self.generate(options = {})
      SpreeReportify::ReportDb[:spree_payment_methods___payment_methods].
      join(:spree_payments___payments, payment_method_id: :id).
      group(:payment_method_name).
      select{[
        :payment_methods__name___payment_method_name,
        count(payments__payment_method_id).as(:payment_count)
      ]}
    end
  end
end
