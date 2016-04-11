module Spree
  class UserPoolReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :orders__completed_at
    HEADERS = { months_name: :string, guest_users: :integer, registered_users: :integer, new_sign_ups: :integer }
    SEARCH_ATTRIBUTES = { start_date: :users_created_from, end_date: :users_created_till }
    SORTABLE_ATTRIBUTES = []

    def generate(options = {})
      # order of column is important when we take union of two tables
      initialize_months_table
      new_sign_ups = SpreeReportify::ReportDb[:spree_users___users].
      where(users__created_at: @start_date..@end_date).
      select{[
        id.as(:user_id),
        Sequel.as(YEAR(:users__created_at), :year),
        Sequel.as(MONTHNAME(:users__created_at), :month_name)
      ]}

      group_new_sign_ups_by_months = SpreeReportify::ReportDb[new_sign_ups].
      right_outer_join(:months, name: :month_name).
      group(:months_name).
      order(:sort_year, :number).
      select{[
        months__number,
        Sequel.as(IFNULL(year, 2016), :sort_year),
        Sequel.as(concat(name, ' ', IFNULL(year, 2016)), :months_name),
        Sequel.as(0, :guest_users),
        Sequel.as(0, :registered_users),
        Sequel.as(IFNULL(COUNT(user_id), 0), :new_sign_ups)
      ]}

      vistors = SpreeReportify::ReportDb[:spree_page_events___page_events].
      where(page_events__created_at: @start_date..@end_date).
      select{[
        Sequel.as(YEAR(:page_events__created_at), :year),
        Sequel.as(MONTHNAME(:page_events__created_at), :month_name),
        Sequel.as(actor_id, :user),
        Sequel.as(session_id, :session)
      ]}

      visitors_by_months = SpreeReportify::ReportDb[vistors].
      right_outer_join(:months, name: :month_name).
      group(:months_name).
      order(:sort_year, :number).
      select{[
        months__number,
        Sequel.as(IFNULL(year, 2016), :sort_year),
        Sequel.as(concat(name, ' ', IFNULL(year, 2016)), :months_name),
        Sequel.as((COUNT(DISTINCT session) - COUNT(DISTINCT user)), :guest_users),
        Sequel.as(COUNT(DISTINCT user), :registered_users),
        Sequel.as(0, :new_sign_ups)
      ]}


      union_of_stats = group_new_sign_ups_by_months.union(visitors_by_months)

      SpreeReportify::ReportDb[union_of_stats].
      group(:months_name).
      order(:sort_year, :number).
      select{[
        months_name,
        Sequel.as(SUM(:guest_users), :guest_users),
        Sequel.as(SUM(:registered_users), :registered_users),
        Sequel.as(SUM(:new_sign_ups), :new_sign_ups)
      ]}
    end

    def select_columns(dataset)
      dataset
    end

    def chart_data
      SpreeReportify::ReportDb[generate].
      select{[
        Sequel.as(group_concat(months_name), :months_name),
        Sequel.as(group_concat(new_sign_ups), :new_sign_ups),
        Sequel.as(group_concat(:registered_users), :registered_users),
        Sequel.as(group_concat(:guest_users), :guest_users)
      ]}.all
    end

    def chart_json
      chart_data = self.chart_data.first
      {
        chart: true,
        charts: [
          {
            id: 'user-pool',
            json: {
              chart: { type: 'column' },
              title: { text: 'User Pool' },
              xAxis: { categories: chart_data[:months_name].split(',') },
              yAxis: {
                title: { text: 'Value($)' }
              },
              legend: {
                  layout: 'vertical',
                  align: 'right',
                  verticalAlign: 'middle',
                  borderWidth: 0
              },
              series: [
                {
                  name: Spree.t('user_pool.new_sign_ups'),
                  data: chart_data[:new_sign_ups].split(',').map(&:to_i)
                },
                {
                  name: Spree.t('user_pool.registered_users'),
                  data: chart_data[:registered_users].split(',').map(&:to_i)
                },
                {
                  name: Spree.t('user_pool.guest_users'),
                  data: chart_data[:guest_users].split(',').map(&:to_i)
                }
              ]
            }
          }
        ]
      }
    end
  end
end
