module Spree
  class UsersWhoRecentlyPurchasedReport < Spree::Report
    HEADERS = [:user_email, :purchase_count, :last_purchase_date, :last_purchased_order_number]

    def self.generate(options = {})
      all_orders_with_users = SpreeReportify::ReportDb[:spree_users___users].
      left_join(:spree_orders___orders, user_id: :id).
      where(Sequel.~(orders__completed_at: nil)).
      order(Sequel.desc(:orders__completed_at)).
      select(:users__email, :orders__number, :orders__completed_at).
      as(:all_orders_with_users)

      SpreeReportify::ReportDb[all_orders_with_users].
      select{[
        all_orders_with_users__email,
        all_orders_with_users__number,
        all_orders_with_users__completed_at,
        count(all_orders_with_users__number).as(orders_count)
      ]}.
      group(:all_orders_with_users__email)
    end
  end
end
