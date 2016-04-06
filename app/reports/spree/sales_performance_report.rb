module Spree
  class SalesPerformanceReport < Spree::Report
    HEADERS = { revenue: :integer, tax: :integer, shipping_charges: :integer, refund_amount: :integer, adjustment_total: :integer }
    SEARCH_ATTRIBUTES = { start_date: :orders_created_from, end_date: :orders_created_till }
    SORTABLE_ATTRIBUTES = []

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
        where(refunds__created_at: @start_date..@end_date). #filter by params
        select{[Sequel.as(CONCAT(::Money.new(Spree::Config[:currency]).symbol, IFNULL(sum(:amount), 0)), :refund_amount)]}
      ]
    end

    def chart_json
      {
        chart: true,
        json: {
          title: {
            text: 'Sales Performance'
          },
          xAxis: {
            categories: chart_data[:months_name].split(',')
          },
          yAxis: {
            title: {
              text: 'Value($)'
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
          },
          tooltip: {
            valuePrefix: '$'
          },
          legend: {
              layout: 'vertical',
              align: 'right',
              verticalAlign: 'middle',
              borderWidth: 0
          },
          series: [
            {
              name: 'Revenue',
              data: chart_data[:revenue].split(',').map(&:to_i)
            },
            {
              name: 'Shipping Charges',
              data: chart_data[:shipping_charges].split(',').map(&:to_i)
            },
            {
              name: 'Tax',
              data: chart_data[:tax].split(',').map(&:to_i)
            },
            {
              name: 'Refunds',
              data: chart_data[:refunds].split(',').map(&:to_i)
            }
          ]
        }
      }
    end

    def chart_data
      unless SpreeReportify::ReportDb.table_exists?(:months)
        SpreeReportify::ReportDb.create_table :months, temp: true do
          column :name, :text
          column :number, :integer
        end
        months_table = SpreeReportify::ReportDb[:months]
        month_names = Date::MONTHNAMES.dup
        month_names.shift(1)
        month_names.each_with_index { |month_name, index| months_table.insert(name: month_name, number: index) }
      end
      orders_with_monthname = SpreeReportify::ReportDb[:spree_orders___orders].
      exclude(completed_at: nil).
      where(orders__created_at: @start_date..@end_date). #filter by params
      select{[
        Sequel.as(MONTHNAME(:orders__created_at), :month_name),
        Sequel.as(YEAR(:orders__created_at), :year),
        Sequel.as(CONCAT(MONTHNAME(:orders__created_at), ' ', YEAR(:orders__created_at)), :month_year),
        orders__total,
        Sequel.as((orders__additional_tax_total + orders__included_tax_total), :tax),
        orders__shipment_total
      ]}.as(:order_months)

      orders_join_with_months = SpreeReportify::ReportDb[orders_with_monthname].
      right_outer_join(:months, name: :month_name).
      group(:months_name).
      order(:sort_year, :number).
      select{[
        months__number,
        Sequel.as(IFNULL(year, 2016), :sort_year),
        month_year,
        Sequel.as(concat(name, IFNULL(year, 2016)), :months_name),
        Sequel.as(IFNULL(sum(total), 0), :revenue),
        Sequel.as(IFNULL(sum(tax), 0), :tax),
        Sequel.as(IFNULL(sum(shipment_total), 0), :shipping_charges)
      ]}

      @data ||= SpreeReportify::ReportDb[orders_join_with_months].
      select{[
        Sequel.as(group_concat(revenue), :revenue),
        Sequel.as(group_concat(tax), :tax),
        Sequel.as(group_concat(shipping_charges), :shipping_charges),
        Sequel.as(group_concat(months_name), :months_name)
      ]}.all.
      first.
      merge(
        (refunds_with_monthname = SpreeReportify::ReportDb[:spree_refunds___refunds].
        where(refunds__created_at: @start_date..@end_date). #filter by params
        select{[
          Sequel.as(MONTHNAME(:refunds__created_at), :month_name),
          Sequel.as(YEAR(:refunds__created_at), :year),
          Sequel.as(CONCAT(MONTHNAME(:refunds__created_at), ' ', YEAR(:refunds__created_at)), :month_year),
          Sequel.as(amount, :refund_amount)
        ]}

        refunds_join_with_months = SpreeReportify::ReportDb[refunds_with_monthname].
        right_outer_join(:months, name: :month_name).
        group(:months_name).
        order(:sort_year, :number).
        select{[
          months__number,
          Sequel.as(IFNULL(year, 2016), :sort_year),
            month_year,
            Sequel.as(concat(name, IFNULL(year, 2016)), :months_name),
          Sequel.as(IFNULL(sum(refund_amount), 0), :refunds)
        ]}

        SpreeReportify::ReportDb[refunds_join_with_months].
        select{[
          Sequel.as(group_concat(refunds), :refunds)
        ]}.all.first)
      )
    end
  end
end
