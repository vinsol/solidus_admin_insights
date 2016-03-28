module Spree
  class TrendingSearchReport < Spree::Report
    HEADERS = [:searched_term, :occurrences]

    def self.assign_search_params(options)
      super
      @search_keywords_cont = @search[:keywords_cont].present? ? "%#{ @search[:keywords_cont] }%" : '%'
    end

    def self.generate(options = {})
      assign_search_params(options)
      SpreeReportify::ReportDb[:spree_page_events___page_events].
      where(page_events__activity: 'search').
      where(page_events__created_at: @start_date..@end_date).where(Sequel.ilike(:page_events__search_keywords, @search_keywords_cont)). #filter by params
      group(:searched_term).
      order(Sequel.desc(:occurrences)).
      select{[
        :search_keywords___searched_term,
        Sequel.as(count(:search_keywords), :occurrences)
      ]}
    end
  end
end
