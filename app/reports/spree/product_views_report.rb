module Spree
  class ProductViewsReport < Spree::Report
    HEADERS = [:product_name, :views, :users, :guest_sessions]

    def self.generate(options = {})
      unique_session_results = ::SpreeReportify::ReportDb[:spree_products___products].
      join(:spree_page_events___page_events, target_id: :id).
      where(page_events__target_type: 'Spree::Product', page_events__activity: 'view').
      group(:product_name, :page_events__actor_id, :page_events__session_id).
      select{[
        products__name.as(product_name),
        count('*').as(total_views_per_session),
        page_events__session_id.as(session_id),
        page_events__actor_id.as(actor_id)
      ]}.as(:unique_session_results)

      ::SpreeReportify::ReportDb[unique_session_results].select{[
        product_name,
        sum(total_views_per_session).as(views),
        count(DISTINCT actor_id).as(users),
        (COUNT(DISTINCT session_id) - COUNT(actor_id)).as(guest_sessions)
      ]}.group(:product_name)
    end
  end
end
