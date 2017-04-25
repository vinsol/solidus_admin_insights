module Spree
  class UsersNotConvertedReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :orders__completed_at
    HEADERS = { user_email: :string, signup_date: :date }
    SEARCH_ATTRIBUTES = { start_date: :users_created_from, end_date: :users_created_till, email_cont: :email }
    SORTABLE_ATTRIBUTES = [:user_email, :signup_date]

    def arel?
      true
    end

    def initialize(options)
      super
      @sortable_type = :desc if options[:sort].blank?
      @email_cont = @search[:email_cont].present? ? "%#{ @search[:email_cont] }%" : '%'
      @record_per_page = options['records_per_page']
      @offset = options['offset']
    end

    class Result < Spree::Report::Result
      def build_report_from_query(query)
        populate_results(query)
        user_db_results_as_reports
      end
    end

    def report_query
      Spree::User
        .where(created_at: @start_date..@end_date)
        .where(Spree::User.arel_table[:email].matches("%#{ @email_cont }%"))
        .left_joins(:spree_orders)
        .where(spree_orders: { completed_at: nil, number: nil })
        .select("spree_users.email as  user_email", "spree_users.created_at as signup_date")
        .limit(@record_per_page)
        .offset(@offset)
        .order(sortable_attribute) # Missing order direction
    end

    def select_columns(dataset)
      dataset
    end
  end
end
