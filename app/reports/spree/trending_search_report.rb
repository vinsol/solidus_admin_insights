module Spree
  class TrendingSearchReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :occurrences
    HEADERS = { searched_term: :string, occurrences: :integer }
    SEARCH_ATTRIBUTES = { start_date: :start_date, end_date: :end_date, keywords_cont: :keyword }
    SORTABLE_ATTRIBUTES = [:occurrences]

    def initialize(options)
      super
      @search_keywords_cont = @search[:keywords_cont].present? ? "%#{ @search[:keywords_cont] }%" : '%'
      @sortable_type = :desc if options[:sort].blank?
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    def generate(options = {})
      SpreeReportify::ReportDb[:spree_page_events___page_events].
      where(page_events__activity: 'search').
      where(page_events__created_at: @start_date..@end_date).where(Sequel.ilike(:page_events__search_keywords, @search_keywords_cont)). #filter by params
      group(:searched_term).
      order(Sequel.desc(:occurrences))
    end

    def select_columns(dataset)
      dataset.select{[
        search_keywords.as(searched_term),
        Sequel.as(count(:search_keywords), :occurrences)
      ]}
    end
  end
end
