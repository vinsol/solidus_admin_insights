module Spree
  class ReportGenerationService

    REPORTS = {
      finance_analysis:           [:payment_method_transactions, :payment_method_transactions_conversion_rate],
      product_analysis:           [:cart_additions, :cart_removals, :cart_updations],
      sales_performance_analysis: [:sales_performance],
      trending_search_analysis:   [:trending_search],
      user_analysis:              [:users_not_converted, :users_who_recently_purchased, :users_who_have_not_recently_purchased]
    }

    # REPORTS = {
    #   product_analysis: {
    #     product_views: {
    #       headers: [:product_name, :views, :users, :guest_sessions]
    #     },
    #     cart_additions: {
    #       headers: [:product_name, :additions, :quantity_change]
    #     },
    #     cart_removals: {
    #       headers: [:product_name, :removals, :quantity_change]
    #     },
    #     cart_updations: {
    #       headers: [:product_name, :updations, :quantity_increase, :quantity_decrease]
    #     },
    #     product_views_to_cart_additions: {
    #       headers: [:product_name, :views, :cart_additions]
    #     },
    #     product_views_to_purchases: {
    #       headers: [:product_name, :views, :purchases]
    #     },
    #     best_selling_products: {
    #       headers: [:product_name, :sold_count]
    #     },
    #     unique_purchases: {
    #       headers: [:product_name, :sold_count, :users]
    #     }
    #   },
    #   trending_search_analysis: {
    #     trending_searches: {
    #       headers: [:searched_term, :occurrences]
    #     }
    #   },
    #   user_analysis: {
    #     users_not_converted: {
    #       headers: [:user_email, :signup_date]
    #     },
    #     users_who_recently_purchased: {
    #       headers: [:user_email, :purchase_count, :last_purchase_date, :last_purchased_order_number]
    #     },
    #     users_who_have_not_recently_purchased: {
    #       headers: [:user_email, :last_purchase_date, :last_purchased_order_number]
    #     }
    #   },
    #   finance_analysis: {
    #     payment_method_transactions: {
    #       headers: [:payment_method_name, :payment_count]
    #     },
    #     payment_method_transactions_conversion_rate: {
    #       headers: [:payment_method_name, :successful_payments_count, :failed_payments_count]
    #     }
    #   },
    #   promotion_analysis: {
    #     promotional_cost: {
    #       headers: [:promotion_name, :usage_count, :promotion_discount]
    #     }
    #   },
    #   sales_performance_analysis: {
    #     sales_performance: {
    #       headers: [:revenue, :tax, :shipping_charges, :refund_amount]
    #     }
    #   }
    # }

    # def self.product_views(options = {})
    #   product_view = Struct.new(*REPORTS[options[:type].to_sym][:product_views][:headers])
    #   search = PageEvent.product_pages.activity(PageEvent::ACTIVITIES[:view]).ransack(options[:q])
    #   product_views = search.result.group_by(&:target_id).map do |_id, page_events|
    #     view = product_view.new(Spree::Product.find_by(id: _id).name)
    #     view.views = page_events.size
    #     view.users = page_events.select(&:actor_id?).uniq(&:actor_id).size
    #     view.guest_sessions = page_events.reject(&:actor_id?).uniq(&:session_id).size
    #     view
    #   end
    #   [search, product_views]
    # end

    def self.cart_additions(options = {})
      search = CartEvent.events(:add).ransack(options[:q])
      cart_additions = Spree::CartAdditionsReport.generate(options).all
      [search, cart_additions]
    end

    def self.cart_removals(options = {})
      search = CartEvent.events(:remove).ransack(options[:q])
      cart_removals = Spree::CartRemovalsReport.generate(options).all
      [search, cart_removals]
    end

    def self.cart_updations(options = {})
      search = CartEvent.events(:update).ransack(options[:q])
      cart_updations = Spree::CartUpdationsReport.generate(options).all
      [search, cart_updations]
    end

    # def self.product_views_to_cart_additions(options = {})
    #   product_to_cart_view = Struct.new(*REPORTS[options[:type].to_sym][:product_views_to_cart_additions][:headers])
    #   product_views_to_cart_additions = self.product_views(options).second.map do |product_view|
    #     product_to_cart_view.new(product_view.product_name, product_view.views)
    #   end

    #   self.cart_additions(options).second.each do |cart_addition|
    #     product_view_cart_addition = product_views_to_cart_additions.
    #     find(ifnone = product_to_cart_view.new(cart_addition.product_name)) do |view|
    #       view.product_name == cart_addition.product_name
    #     end
    #     product_view_cart_addition.cart_additions = cart_addition.additions
    #   end
    #   [self.product_views(options).first, product_views_to_cart_additions]
    # end

    # def self.product_views_to_purchases(options = {})
    #   product_purchases_view = Struct.new(*REPORTS[options[:type].to_sym][:product_views_to_purchases][:headers])
    #   search = PageEvent.product_pages.activity(PageEvent::ACTIVITIES[:view]).ransack(options[:q])
    #   search_results = search.result
    #   sold_line_items = LineItem.of_completed_orders.for_products(search_results.map(&:target_id))
    #   product_views_to_purchases = sold_line_items.group_by(&:product).map do |product, line_items|
    #     view = product_purchases_view.new(product.name)
    #     view.views = search_results.select { |product_view| product_view.target_id == product.id }.size
    #     view.purchases = line_items.sum(&:quantity)
    #     view
    #   end
    #   [search, product_views_to_purchases]
    # end

    # def self.best_selling_products(options = {})
    #   best_selling_view = Struct.new(*REPORTS[options[:type].to_sym][:best_selling_products][:headers])
    #   search = LineItem.of_completed_orders.ransack(options[:q])
    #   best_selling_products = search.result.group_by(&:product).map do |product, line_items|
    #     view = best_selling_view.new(product.name)
    #     view.sold_count = line_items.sum(&:quantity)
    #     view
    #   end.sort_by(&:sold_count).reverse
    #   [search, best_selling_products]
    # end

    # def self.unique_purchases(options = {})
    #   unique_purchases_view = Struct.new(*REPORTS[options[:type].to_sym][:unique_purchases][:headers])
    #   search = LineItem.of_completed_orders.ransack(options[:q])
    #   unique_purchases_views = search.result.group_by(&:product).map do |product, line_items|
    #     view = unique_purchases_view.new(product.name)
    #     view.sold_count = line_items.sum(&:quantity)
    #     partitioned_line_items = line_items.partition(&:user)
    #     view.users = partitioned_line_items.second.size + partitioned_line_items.first.uniq(&:user).size
    #     view
    #   end
    #   [search, unique_purchases_views]
    # end

    def self.trending_search(options = {})
      search = PageEvent.activity(PageEvent::ACTIVITIES[:search]).ransack(options[:q])
      trending_searches = Spree::TrendingSearchReport.generate(options).all
      [search, trending_searches]
    end

    def self.users_not_converted(options = {})
      search = Spree.user_class.ransack(options[:q])
      users_not_converted = Spree::UsersNotConvertedReport.generate(options).all
      [search, users_not_converted]
    end

    def self.users_who_recently_purchased(options = {})
      search = Spree.user_class.ransack(options[:q])
      users_who_recently_purchased = Spree::UsersWhoRecentlyPurchasedReport.generate(options).all
      [search, users_who_recently_purchased]
    end

    def self.users_who_have_not_recently_purchased(options = {})
      search = Spree.user_class.ransack(options[:q])
      users_who_have_not_recently_purchased = Spree::UsersWhoHaveNotRecentlyPurchasedReport.generate(options).all
      [search, users_who_have_not_recently_purchased]
    end

    def self.payment_method_transactions(options = {})
      search = Spree::PaymentMethod.ransack(options[:q])
      payment_method_transactions = Spree::PaymentMethodTransactionsReport.generate(options).all
      [search, payment_method_transactions]
    end

    def self.payment_method_transactions_conversion_rate(options = {})
      search = Spree::PaymentMethod.ransack(options[:q])
      payment_method_transactions_conversion_rate = Spree::PaymentMethodTransactionsConversionRateReport.generate(options).all
      [search, payment_method_transactions_conversion_rate]
    end

    # def self.promotional_cost(options = {})
    #   promotional_cost_view = Struct.new(*REPORTS[options[:type].to_sym][:promotional_cost][:headers])
    #   search = Adjustment.promotion.ransack(options[:q])
    #   promotional_cost_views = search.result.group_by(&:promotion).map do |promotion, adjustments|
    #     view = promotional_cost_view.new(promotion.try(:name))
    #     view.promotion_discount = adjustments.sum(&:amount).abs
    #     view.usage_count = adjustments.size
    #     view
    #   end
    #   [search, promotional_cost_views]
    # end

    def self.sales_performance(options = {})
      search = Order.complete.ransack(options[:q])
      sales_performances, refunds = Spree::SalesPerformanceReport.generate(options)
      [search, [sales_performances.all.first.merge(refunds.all.first)]]
    end

  end
end
