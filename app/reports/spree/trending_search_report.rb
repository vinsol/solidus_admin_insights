module Spree
  class TrendingSearchReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :occurrences
    HEADERS = { searched_term: :string, occurrences: :integer }
    SEARCH_ATTRIBUTES = { start_date: :start_date, end_date: :end_date, keywords_cont: :keyword }
    SORTABLE_ATTRIBUTES = []

    def deeplink_properties
      {
        deeplinked: true,
        searched_term: { template: %Q{<a href='/products?utf8=%E2%9C%93&keywords={%# o['searched_term'] %}' target="_blank">{%# o['searched_term'] %}</a>} }
      }
    end

    def initialize(options)
      super
      @search_keywords_cont = @search[:keywords_cont].present? ? "%#{ @search[:keywords_cont] }%" : '%'
      @sortable_type = :desc if options[:sort].blank?
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    class Result < Spree::Report::Result
      def build_report_from_query(query)
        populate_results(query)
        user_db_results_as_reports
      end
    end

    def arel?
      true
    end

    def report_query(options = {})
      searches =
        Spree::PageEvent
          .where(activity: 'search')
          .where(created_at: @start_date..@end_date)
          .where(Spree::PageEvent.arel_table[:search_keywords].matches("%#{ @search_keywords_cont }%"))
          .select("search_keywords as searched_term")

      Spree::Report::QueryFragments.from_subquery(searches)
        .project("count(searched_term) as occurrences", "searched_term")
        .group("searched_term")
        .take(20)

    end

    def select_columns(dataset)
      dataset
    end

    def chart_data
      top_searches = select_columns(generate)
      total_occurrences = top_searches.inject(0) { |sum, search| sum += search[:occurrences] }
      top_searches.collect { |search| { name: search[:searched_term], y: (search[:occurrences].to_f/total_occurrences) }  }
    end

    def chart_json
      {
        chart: true,
        charts: [
          {
            name: 'trending-search',
            json: {
              chart: { type: 'pie' },
              title: {
                useHTML: true,
                text: "<span class='chart-title'>Trending Search Keywords(Top 20)</span><span class='fa fa-question-circle' data-toggle='tooltip' title='Track the most trending keywords searched by users'></span>"
              },
              tooltip: {
                  pointFormat: 'Search %: <b>{point.percentage:.1f}%</b>'
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
                  name: 'Hits',
                  data: chart_data
              }]
            }
          }
        ]
      }
    end

  end
end
