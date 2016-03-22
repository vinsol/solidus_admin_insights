module Spree
  class ProductViewsReport < Spree::Report
    HEADERS = [:product_name, :views, :users, :guest_sessions]

    def self.generate(options = {})
    end
  end
end
