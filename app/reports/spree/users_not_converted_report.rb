module Spree
  class UsersNotConvertedReport < Spree::Report
    HEADERS = [:user_email, :signup_date]

    def initialize(options)
      super
      @email_cont = @search[:email_cont].present? ? "%#{ @search[:email_cont] }%" : '%'
    end

    def generate(options = {})
      SpreeReportify::ReportDb[:spree_users___users].
      left_join(:spree_orders___orders, user_id: :id).
      where(orders__completed_at: nil, orders__number: nil).
      where(users__created_at: @start_date..@end_date).where(Sequel.ilike(:users__email, @email_cont)). #filter by params
      order(Sequel.desc(:orders__completed_at))
    end

    def select_columns(dataset)
      dataset.select(
        :users__email___user_email,
        :users__created_at___signup_date)
    end
  end
end
