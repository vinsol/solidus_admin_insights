module Spree
  class UserPoolReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :orders__completed_at
    HEADERS = { months_name: :string, guest_users: :integer, active_users: :integer, new_sign_ups: :integer }
    SEARCH_ATTRIBUTES = { start_date: :users_created_from, end_date: :users_created_till }
    SORTABLE_ATTRIBUTES = []


    class Result < Spree::Report::Result
      def empty_slice
        { active_users: 0, guest_users: 0, new_sign_ups: 0 }
      end
    end

    def paginated?
      false
    end

    def report_query
      Report::QueryFragments
        .from_union(grouped_sign_ups, grouped_visitors)
        .group(*zoom_columns)
        .order(*zoom_columns_to_s)
        .project(
          *zoom_columns,
          'SUM(active_users) as active_users',
          'SUM(guest_users) as guest_users',
          'SUM(new_sign_ups) as new_sign_ups'
        )
    end

    def grouped_sign_ups
      sign_ups = Spree::User.where(created_at: @start_date..@end_date).select(:id, *zoom_selects)

      Report::QueryFragments.from_subquery(sign_ups)
        .group(*zoom_columns, 'guest_users', 'active_users')
        .order(*zoom_columns_to_s)
        .project(
          *zoom_columns,
          '0 as guest_users',
          '0 as active_users',
          'COUNT(id) as new_sign_ups'
        )
    end

    def grouped_visitors
      visitors = Spree::PageEvent.where(created_at: @start_date..@end_date).select(*zoom_selects, 'actor_id AS user', 'session_id AS session')
      Report::QueryFragments.from_subquery(visitors)
        .group(*zoom_columns, 'new_sign_ups')
        .order(*zoom_columns_to_s)
        .project(
          *zoom_columns,
          '(COUNT(DISTINCT(session)) - COUNT(DISTINCT(user))) AS guest_users',
          'COUNT(DISTINCT(user)) as active_users', '0 as new_sign_ups'
        )
    end

    def select_columns(dataset)
      dataset
    end

    # extract it in report.rb
    def chart_data
      unless @data
        @data = Hash.new {|h, k| h[k] = [] }
        generate.each do |object|
          object.each_pair do |key, value|
            @data[key].push(value)
          end
        end
      end
      @data
    end

    def chart_json
      {
        chart: true,
        charts: [
          {
            id: 'user-pool',
            json: {
              chart: { type: 'column' },
              title: {
                useHTML: true,
                text: %Q(<span class="chart-title">User Pool</span>
                         <span class="fa fa-question-circle"
                               data-toggle="tooltip"
                               title=" Keep a track of different type of users such as guest users, registered users and newly signed up users">
                         </span>)
              },
              xAxis: { categories: chart_data[:months_name] },
              yAxis: {
                title: { text: 'Count' }
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
                  data: chart_data[:new_sign_ups].map(&:to_i)
                },
                {
                  name: Spree.t('user_pool.active_users'),
                  data: chart_data[:active_users].map(&:to_i)
                },
                {
                  name: Spree.t('user_pool.guest_users'),
                  data: chart_data[:guest_users].map(&:to_i)
                }
              ]
            }
          }
        ]
      }
    end
  end
end
