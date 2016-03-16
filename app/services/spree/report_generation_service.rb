module Spree
  class ReportGenerationService
    REPORTS = {
      product_views: { headers: [:product_name, :view_count, :user_count] }
    }

    def self.product_views
      product_view = Struct.new(*REPORTS[:product_views][:headers])
      product_page_events = PageEvent.where(object_type: Spree::Product)
    end
  end
end
