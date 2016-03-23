module Spree
  class TrendingSearchReport < Spree::Report
    HEADERS = [:searched_term, :occurrences]

    def self.generate(options = {})
      SpreeReportify::ReportDb[:spree_page_events___page_events].
      where(page_events__activity: 'search').
      group(:searched_term).
      order(Sequel.desc(:occurences)).
      select{[
        :search_keywords___searched_term,
        Sequel.as(count(:search_keywords), :occurences)
      ]}
    end
  end
end
