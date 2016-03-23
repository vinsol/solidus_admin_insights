module Spree
  class ReportGenerationService

    REPORTS = {
      finance_analysis:           [:payment_method_transactions, :payment_method_transactions_conversion_rate],
      product_analysis:           [
                                    :cart_additions, :cart_removals, :cart_updations,
                                    :product_views, :product_views_to_cart_additions,
                                    :product_views_to_purchases, :unique_purchases,
                                    :best_selling_products
                                  ],
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

    def self.product_views(options = {})
      search = PageEvent.product_pages.activity(PageEvent::ACTIVITIES[:view]).ransack(options[:q])
      product_views = Spree::ProductViewsReport.generate(options).all
      [search, product_views]
    end

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

    def self.product_views_to_cart_additions(options = {})
      product_views_to_cart_additions = Spree::ProductViewsToCartAdditionsReport.generate(options).all
      [self.product_views(options).first, product_views_to_cart_additions]
    end

    def self.product_views_to_purchases(options = {})
      search = PageEvent.product_pages.activity(PageEvent::ACTIVITIES[:view]).ransack(options[:q])
      product_views_to_purchases = Spree::ProductViewsToPurchasesReport.generate(options).all
      [search, product_views_to_purchases]
    end

    def self.best_selling_products(options = {})
      search = LineItem.of_completed_orders.ransack(options[:q])
      best_selling_products = Spree::BestSellingProductsReport.generate(options).all
      [search, best_selling_products]
    end

    def self.unique_purchases(options = {})
      search = LineItem.of_completed_orders.ransack(options[:q])
      unique_purchases_views = Spree::UniquePurchasesReport.generate(options).all
      [search, unique_purchases_views]
    end

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
