module Spree
  class AnnualPromotionalCostReport < Spree::PromotionalCostReport
    DEFAULT_SORTABLE_ATTRIBUTE = :promotion_name
    HEADERS = { promotion_name: :string, usage_count: :integer, promotion_discount: :integer }
    SEARCH_ATTRIBUTES = {}
    SORTABLE_ATTRIBUTES = []

    def generate
      super
      data = []
      group_by_promotion_name.each_pair do |promotion_name, collection|
        data << { promotion_name: promotion_name, promotion_discount: collection.sum { |r| r[:promotion_discount] }, usage_count: collection.sum { |r| r[:usage_count] } }
      end
      data
    end

    def chart_data
      data = generate
      total_discount = (data.sum { |r| r[:promotion_discount] } / 100)
      data.map { |r| { name: r[:promotion_name], y: (r[:promotion_discount] / total_discount).to_f } }
    end

    def chart_json
      {
        chart: true,
        charts: [
          {
            name: 'annual-promotional-cost',
            json: {
              chart: { type: 'pie' },
              title: {
                useHTML: true,
                text: '<span class="chart-title">Annual Promotional Cost</span><span class="glyphicon glyphicon-question-sign" data-toggle="tooltip" title="Compare the costing for various promotions"></span>'
              },
              tooltip: {
                  pointFormat: 'Cost %: <b>{point.percentage:.1f}%</b>'
              },
              plotOptions: {
                  pie: {
                      allowPointSelect: true,
                      cursor: 'pointer',
                      dataLabels: {
                          enabled: false
                      },
                      showInLegend: true
                  }
              },
              series: [{
                  name: 'Annual Promotion',
                  data: chart_data
              }]
            }
          }
        ]
      }
    end
  end
end
