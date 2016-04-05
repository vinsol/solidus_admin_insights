module Spree
  class SalesPerformanceReport < Spree::Report
    HEADERS = [:revenue, :tax, :shipping_charges, :refund_amount, :adjustment_total]
    SEARCH_ATTRIBUTES = { start_date: :orders_created_from, end_date: :orders_created_till }

    def generate(options = {})
      [
        SpreeReportify::ReportDb[:spree_orders___orders].
        exclude(completed_at: nil).
        where(orders__created_at: @start_date..@end_date). #filter by params
        select{[
          Sequel.as(CONCAT(::Money.new(Spree::Config[:currency]).symbol, IFNULL(sum(orders__total), 0)), :revenue),
          Sequel.as(CONCAT(::Money.new(Spree::Config[:currency]).symbol, IFNULL(sum(orders__additional_tax_total) + sum(orders__included_tax_total), 0)), :tax),
          Sequel.as(CONCAT(::Money.new(Spree::Config[:currency]).symbol, IFNULL(sum(orders__shipment_total), 0)), :shipping_charges),
          Sequel.as(CONCAT(::Money.new(Spree::Config[:currency]).symbol, IFNULL(sum(orders__adjustment_total), 0)), :adjustment_total)
        ]},

        SpreeReportify::ReportDb[:spree_refunds___refunds].
        select{[Sequel.as(CONCAT(::Money.new(Spree::Config[:currency]).symbol, IFNULL(sum(:amount), 0)), :refund_amount)]}
      ]
    end
  end
end
