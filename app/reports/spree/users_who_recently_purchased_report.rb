module Spree
  class UsersWhoRecentlyPurchasedReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :user_email
    HEADERS                    = { user_email: :string, purchase_count: :integer, last_purchase_date: :date, last_purchased_order_number: :string }
    SEARCH_ATTRIBUTES          = { start_date: :start_date, end_date: :end_date, email_cont: :email }
    SORTABLE_ATTRIBUTES        = [:user_email, :purchase_count, :last_purchase_date]

    def paginated?
      true
    end

    class Result < Spree::Report::Result
      class Observation < Spree::Report::Observation
        observation_fields [:user_email, :last_purchased_order_number, :last_purchase_date, :purchase_count]

        def last_purchase_date
          @last_purchase_date.to_date.strftime("%B %d, %Y")
        end
      end
    end

    def record_count_query
      Spree::Report::QueryFragments.from_subquery(report_query).project(Arel.star.count)
    end

    def report_query
      Spree::Report::QueryFragments
        .from_subquery(all_orders_with_users)
        .project(
          "user_email",
          "last_purchased_order_number",
          "last_purchase_date",
          "COUNT(user_email) as purchase_count")
        .group(
          "user_email",
          "last_purchased_order_number",
          "last_purchase_date"
        )
    end


    def paginated_report_query
      report_query
        .take(records_per_page)
        .skip(current_page)
    end

    private def all_orders_with_users
      Spree::User
        .where(Spree::User.arel_table[:email].matches(email_search))
        .left_joins(:spree_orders)
        .where(spree_orders: { completed_at: reporting_period })
        .order("spree_orders.completed_at desc")
        .select(
          "spree_users.email          as user_email",
          "spree_orders.number        as last_purchased_order_number",
          "spree_orders.completed_at  as last_purchase_date"
        ).group(
          'user_email',
          "spree_orders.number",
          "spree_orders.completed_at"
        )
    end

    private def email_search
      search[:email_cont].present? ? "%#{ search[:email_cont] }%" : '%'
    end
  end
end
