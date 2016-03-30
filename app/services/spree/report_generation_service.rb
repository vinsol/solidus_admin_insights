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
      generate_report(Spree::ProductViewsReport, options)
    end

    def self.cart_additions(options = {})
      generate_report(Spree::CartAdditionsReport, options)
    end

    def self.cart_removals(options = {})
      generate_report(Spree::CartRemovalsReport, options)
    end

    def self.cart_updations(options = {})
      generate_report(Spree::CartUpdationsReport, options)
    end

    def self.product_views_to_cart_additions(options = {})
      generate_report(Spree::ProductViewsToCartAdditionsReport, options)
    end

    def self.product_views_to_purchases(options = {})
      generate_report(Spree::ProductViewsToPurchasesReport, options)
    end

    def self.best_selling_products(options = {})
      generate_report(Spree::BestSellingProductsReport, options)
    end

    def self.unique_purchases(options = {})
      generate_report(Spree::UniquePurchasesReport, options)
    end

    def self.trending_search(options = {})
      generate_report(Spree::TrendingSearchReport, options)
    end

    def self.users_not_converted(options = {})
      generate_report(Spree::UsersNotConvertedReport, options)
    end

    def self.users_who_recently_purchased(options = {})
      generate_report(Spree::UsersWhoRecentlyPurchasedReport, options)
    end

    def self.users_who_have_not_recently_purchased(options = {})
      generate_report(Spree::UsersWhoHaveNotRecentlyPurchasedReport, options)
    end

    def self.payment_method_transactions(options = {})
      generate_report(Spree::PaymentMethodTransactionsReport, options)
    end

    def self.payment_method_transactions_conversion_rate(options = {})
      generate_report(Spree::PaymentMethodTransactionsConversionRateReport, options)
    end

    def self.promotional_cost(options = {})
      generate_report(Spree::PromotionalCostReport, options)
    end

    def self.sales_performance(options = {})
      sales_performances, refunds = Spree::SalesPerformanceReport.generate(options)
      [[sales_performances.all.first.merge(refunds.all.first)], 1]
    end

    def self.generate_report(klass, options)
      dataset = klass.generate(options)
      total_records = klass.select_columns(dataset).count
      result_set = klass.select_columns(dataset.limit(options['records_per_page'], options['offset'])).all
      [result_set, total_records]
    end
  end
end
