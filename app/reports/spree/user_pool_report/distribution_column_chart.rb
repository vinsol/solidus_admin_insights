class Spree::UserPoolReport::DistributionColumnChart
  def initialize(result)
    @chart_data = {
      active_users: [],
      guest_users: [],
      new_sign_ups: []
    }
    @time_dimension = result.time_dimension
    @chart_data[@time_dimension] = []
    @result = result
    process_chart_data
  end

  def process_chart_data
    chart_keys = @chart_data.keys
    @result.observations.each do |observation|
      chart_keys.each do |key|
        @chart_data[key] << observation.public_send(key)
      end
    end
  end

  def to_h
    {
      id: 'user-pool',
      json: {
        chart: { type: 'column' },
        title: {
          useHTML: true,
          text: %Q(
                         <span class="chart-title">User Pool</span>
                         <span class="fa fa-question-circle"
                               data-toggle="tooltip"
                               title=" Keep a track of different type of users such as guest users, registered users and newly signed up users">
                         </span>
                         )
        },
        xAxis: { categories: @chart_data[@time_dimension] },
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
            data: @chart_data[:new_sign_ups].map(&:to_i)
          },
          {
            name: Spree.t('user_pool.active_users'),
            data: @chart_data[:active_users].map(&:to_i)
          },
          {
            name: Spree.t('user_pool.guest_users'),
            data: @chart_data[:guest_users].map(&:to_i)
          }
        ]
      }
    }
  end
end
