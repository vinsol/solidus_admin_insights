module Spree
  class TrendingSearchReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :occurrences
    HEADERS = { searched_term: :string, occurrences: :integer }
    SEARCH_ATTRIBUTES = { start_date: :start_date, end_date: :end_date, keywords_cont: :keyword }
    SORTABLE_ATTRIBUTES = []

    class Result < Spree::Report::Result
      charts FrequencyDistributionPieChart

      class Observation < Spree::Report::Observation
        observation_fields [:searched_term, :occurrences]
      end
    end

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

    def paginated_report_query
      report_query.take(20)
    end

    def total_records
      count_query = Spree::Report::QueryFragments.from_subquery(report_query).project(Arel.star.count)
      ActiveRecord::Base.connection.select_value(count_query.to_sql)
    end

    def report_query
      searches =
        Spree::PageEvent
          .where(activity: 'search')
          .where(created_at: @start_date..@end_date)
          .where(Spree::PageEvent.arel_table[:search_keywords].matches("%#{ @search_keywords_cont }%"))
          .select("search_keywords as searched_term")

      Spree::Report::QueryFragments.from_subquery(searches)
        .project("count(searched_term) as occurrences", "searched_term")
        .group("searched_term")
    end
  end
end
