module Spree
  class PaymentMethodTransactionsConversionRateReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :payment_method_name
    HEADERS = { payment_state: :string, months_name: :string, count: :integer }
    SEARCH_ATTRIBUTES = { start_date: :payments_created_from, end_date: :payments_created_to }
    SORTABLE_ATTRIBUTES = [:payment_method_name, :successful_payments_count, :failed_payments_count, :pending_payments_count, :invalid_payments_count] 

    def self.no_pagination?
      true
    end

    def generate
      payment_methods = SpreeReportify::ReportDb[:spree_payment_methods___payment_methods].
      join(:spree_payments___payments, payment_method_id: :id).
      where(payments__created_at: @start_date..@end_date). #filter by params
      select{[
        payment_method_id,
        Sequel.as(name, :payment_method_name),
        Sequel.as(state, :payment_state),
        Sequel.as(MONTHNAME(:payments__created_at), :month_name),
        Sequel.as(MONTH(:payments__created_at), :number),
        Sequel.as(YEAR(:payments__created_at), :year)
      ]}

      group_by_months = SpreeReportify::ReportDb[payment_methods].
      group(:months_name, :payment_state).
      order(:year, :number).
      select{[
        number,
        payment_state,
        year,
        Sequel.as(concat(month_name, ' ', year), :months_name),
        Sequel.as(COUNT(payment_method_id), :count),
      ]}

      grouped_by_payment_state = group_by_months.all.group_by { |record| record[:payment_state] }
      data = []
      grouped_by_payment_state.each_pair do |state, collection|
        data << fill_missing_values({ payment_state: state, count: 0 }, collection)
      end
      @data = data.flatten
    end

    def group_by_payment_state
      @grouped_by_payment_state ||= @data.group_by { |record| record[:payment_state] }
    end

    def chart_data
      {
        months_name: group_by_payment_state.first.second.map { |record| record[:months_name] },
        collection: group_by_payment_state
      }
    end

    def chart_json
      {
        chart: true,
        charts: [
          {
            id: 'payment-state',
            json: {
              chart: { type: 'column' },
              title: { text: 'Payment State' },
              xAxis: { categories: chart_data[:months_name] },
              yAxis: {
                title: { text: 'Count' }
              },
              tooltip: { valuePrefix: '#' },
              legend: {
                  layout: 'vertical',
                  align: 'right',
                  verticalAlign: 'middle',
                  borderWidth: 0
              },
              series: chart_data[:collection].map { |key, value| { name: key, data: value.map { |r| r[:count].to_i } } }
            }
          }
        ]
      }
    end

    def select_columns(dataset)
      dataset
    end
  end
end
