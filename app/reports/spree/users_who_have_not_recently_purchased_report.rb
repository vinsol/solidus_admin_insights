module Spree
  class UsersWhoHaveNotRecentlyPurchasedReport < Spree::Report
    HEADERS = [:user_email, :last_purchase_date, :last_purchased_order_number]

    def self.generate(options = {})
      all_orders_with_users = SpreeReportify::ReportDb[:spree_users___users].
      left_join(:spree_orders___orders, user_id: :id).
      where(orders__completed_at: nil, orders__number: nil).
      or(Sequel.~(orders__completed_at: nil)).
      order(Sequel.desc(:orders__completed_at)).
      select(
        :users__email,
        :orders__number,
        :orders__completed_at
      ).as(:all_orders_with_users)

      SpreeReportify::ReportDb[all_orders_with_users].
      select_all.
      group(:all_orders_with_users__email)
    end
  end
end
