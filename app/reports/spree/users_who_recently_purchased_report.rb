module Spree
  class UsersWhoRecentlyPurchasedReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :user_email
    HEADERS = { user_email: :string, purchase_count: :integer, last_purchase_date: :date, last_purchased_order_number: :string }
    SEARCH_ATTRIBUTES = { start_date: :start_date, end_date: :end_date, email_cont: :email }
    SORTABLE_ATTRIBUTES = [:user_email, :purchase_count, :last_purchase_date]

    def initialize(options)
      super
      @email_cont = @search[:email_cont].present? ? "%#{ @search[:email_cont] }%" : '%'
      set_sortable_attributes(options, DEFAULT_SORTABLE_ATTRIBUTE)
      @record_per_page = options['records_per_page']
      @offset = options['offset']
    end

    def arel?
      true
    end

    class Result < Spree::Report::Result
      def build_report_from_query(query)
        populate_results(query)
        use_db_results_as_reports
      end
    end

    def report_query
      all_orders_with_users =
        Spree::User
          .where(Spree::User.arel_table[:email].matches("%#{ @email_cont }%"))
          .left_joins(:spree_orders)
          .where(spree_orders: { completed_at: @start_date..@end_date })
          .order("spree_orders.completed_at desc")
          .select(
            "spree_users.email as user_email",
            "spree_orders.number as last_purchased_order_number",
            "spree_orders.completed_at as last_purchase_date"
          ).group(
            :email,
            "spree_orders.number",
            "spree_orders.completed_at"
          )

      Spree::Report::QueryFragments
        .from_subquery(all_orders_with_users)
        .project(
          "user_email",
          "last_purchased_order_number",
          "last_purchase_date",
          "COUNT(user_email) AS purchase_count")
        .group(
          "user_email",
          "last_purchased_order_number",
          "last_purchase_date"
        )
        .take(@record_per_page)
        .skip(@offset)
    end

    def select_columns(dataset)
      dataset
    end
  end
end
