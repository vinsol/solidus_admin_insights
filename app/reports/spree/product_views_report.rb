module Spree
  class ProductViewsReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :product_name
    HEADERS = { product_name: :string, views: :integer, users: :integer, guest_sessions: :integer }
    SEARCH_ATTRIBUTES = { start_date: :product_view_from, end_date: :product_view_till, name: :name}
    SORTABLE_ATTRIBUTES = [:product_name, :views, :users, :guest_sessions]

    def initialize(options)
      super
      @name = @search[:name].present? ? "%#{ @search[:name] }%" : '%'
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
    end

    def deeplink_properties
      {
        deeplinked: true,
        product_name: { template: %Q{<a href="/admin/products/{%# o.product_slug %}" target="_blank">{%# o.product_name %}</a>} }
      }
    end

    def paginated?
      false
    end

    class Result < Spree::Report::Result
      class Observation < Spree::Report::Observation
        observation_fields [:product_name, :product_slug, :views, :users, :guest_sessions]
      end
    end

    def get_results
      @_results ||= ActiveRecord::Base.connection.execute(report_query.to_sql).to_a
    end

    def report_query
      viewed_events =
        Spree::Product
          .where(Spree::Product.arel_table[:name].matches("%#{ @name }%"))
          .joins(:page_view_events)
          .where(spree_page_events: { created_at: @start_date..@end_date })
          .group('product_name', 'product_slug', 'spree_page_events.actor_id', 'spree_page_events.session_id')
          .select(
            'spree_products.name as product_name',
            'spree_products.slug as product_slug',
            'COUNT(*) as total_views_per_session',
            'spree_page_events.session_id as session_id',
            'spree_page_events.actor_id as actor_id'
          )
      Spree::Report::QueryFragments
        .from_subquery(viewed_events)
        .group('product_name', 'product_slug')
        .project(
          'product_name',
          'product_slug',
          'SUM(total_views_per_session) AS views',
          'COUNT(DISTINCT actor_id) AS users',
          '(COUNT(DISTINCT session_id) - COUNT(actor_id)) AS guest_sessions'
        )
    end

  end
end
