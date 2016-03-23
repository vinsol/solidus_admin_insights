module Spree
  class UsersNotConvertedReport < Spree::Report
    HEADERS = [:user_email, :signup_date]

    def self.generate(options = {})
      SpreeReportify::ReportDb[:spree_users___users].
      left_join(:spree_orders___orders, user_id: :id).
      where(orders__completed_at: nil, orders__number: nil).
      order(Sequel.desc(:orders__completed_at)).
      select(
        :users__email___user_email,
        :users__created_at___signup_date)
    end
  end
end
