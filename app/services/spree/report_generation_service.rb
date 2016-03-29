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
      promotion_analysis:         [:promotional_cost],
      sales_performance_analysis: [:sales_performance],
      trending_search_analysis:   [:trending_search],
      user_analysis:              [:users_not_converted, :users_who_recently_purchased, :users_who_have_not_recently_purchased]
    }

    def self.product_views(options = {})
      product_views = Spree::ProductViewsReport.generate(options).all
    end

    def self.cart_additions(options = {})
      cart_additions = Spree::CartAdditionsReport.generate(options).all
    end

    def self.cart_removals(options = {})
      cart_removals = Spree::CartRemovalsReport.generate(options).all
    end

    def self.cart_updations(options = {})
      cart_updations = Spree::CartUpdationsReport.generate(options).all
    end

    def self.product_views_to_cart_additions(options = {})
      product_views_to_cart_additions = Spree::ProductViewsToCartAdditionsReport.generate(options).all
    end

    def self.product_views_to_purchases(options = {})
      product_views_to_purchases = Spree::ProductViewsToPurchasesReport.generate(options).all
    end

    def self.best_selling_products(options = {})
      best_selling_products = Spree::BestSellingProductsReport.generate(options).all
    end

    def self.unique_purchases(options = {})
      unique_purchases_views = Spree::UniquePurchasesReport.generate(options).all
    end

    def self.trending_search(options = {})
      trending_searches = Spree::TrendingSearchReport.generate(options).all
    end

    def self.users_not_converted(options = {})
      users_not_converted = Spree::UsersNotConvertedReport.generate(options).all
    end

    def self.users_who_recently_purchased(options = {})
      users_who_recently_purchased = Spree::UsersWhoRecentlyPurchasedReport.generate(options).all
    end

    def self.users_who_have_not_recently_purchased(options = {})
      users_who_have_not_recently_purchased = Spree::UsersWhoHaveNotRecentlyPurchasedReport.generate(options).all
    end

    def self.payment_method_transactions(options = {})
      payment_method_transactions = Spree::PaymentMethodTransactionsReport.generate(options).all
    end

    def self.payment_method_transactions_conversion_rate(options = {})
      payment_method_transactions_conversion_rate = Spree::PaymentMethodTransactionsConversionRateReport.generate(options).all
    end

    def self.promotional_cost(options = {})
      promotional_cost_views = Spree::PromotionalCostReport.generate(options).all
    end

    def self.sales_performance(options = {})
      sales_performances, refunds = Spree::SalesPerformanceReport.generate(options)
    end

  end
end
