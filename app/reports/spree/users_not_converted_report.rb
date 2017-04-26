module Spree
  class UsersNotConvertedReport < Spree::Report
    DEFAULT_SORTABLE_ATTRIBUTE = :orders__completed_at
    HEADERS = { user_email: :string, signup_date: :date }
    SEARCH_ATTRIBUTES = { start_date: :users_created_from, end_date: :users_created_till, email_cont: :email }
    SORTABLE_ATTRIBUTES = [:user_email, :signup_date]

    class Result < Spree::Report::Result
      class Observation < Spree::Report::Observation
        observation_fields [:user_email, :signup_date]

        def signup_date
          @signup_date.to_date.strftime("%B %d, %Y")
        end
      end
    end

    def initialize(options)
      super
      @sortable_type = :desc if options[:sort].blank?
      @email_cont = @search[:email_cont].present? ? "%#{ @search[:email_cont] }%" : '%'
    end

    def get_results
      ActiveRecord::Base.connection.execute(report_query.to_sql)
    end

    def total_records
      count_query = Spree::Report::QueryFragments.from_subquery(report_query).project(Arel.star.count)
      ActiveRecord::Base.connection.execute(count_query.to_sql).first["count"].to_i
    end

    def report_query
      Spree::User
        .where(created_at: @start_date..@end_date)
        .where(Spree::User.arel_table[:email].matches("%#{ @email_cont }%"))
        .left_joins(:spree_orders)
        .where(spree_orders: { completed_at: nil, number: nil })
        .select("spree_users.email as  user_email", "spree_users.created_at as signup_date")
        .limit(records_per_page)
        .offset(current_page)
        .order(sortable_attribute) # Missing order direction
    end

  end
end
