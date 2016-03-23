module Spree
  class UsersWhoRecentlyPurchasedReport < Spree::Report
    HEADERS = [:user_email, :purchase_count, :last_purchase_date, :last_purchased_order_number]

    def self.generate(options = {})
      all_orders_with_users = SpreeReportify::ReportDb[:spree_users___users].
      left_join(:spree_orders___orders, user_id: :id).
      where(Sequel.~(orders__completed_at: nil)).
      order(Sequel.desc(:orders__completed_at)).
      select(
        :users__email___user_email,
        :orders__number___last_purchased_order_number,
        :orders__completed_at___last_purchase_date,
      ).as(:all_orders_with_users)

      SpreeReportify::ReportDb[all_orders_with_users].
      select{[
        all_orders_with_users__user_email,
        all_orders_with_users__last_purchased_order_number,
        all_orders_with_users__last_purchase_date,
        count(all_orders_with_users__user_email).as(purchase_count)
      ]}.
      group(:all_orders_with_users__user_email)
    end
  end
end
