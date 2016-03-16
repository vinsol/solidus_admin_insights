module Spree
  class ReportGenerationService
    REPORTS = {
      product_views: { headers: [:product_name, :view_count, :user_count, :guest_sessions] }
    }

    def self.product_views
      product_view = Struct.new(*REPORTS[:product_views][:headers])
      product_page_events = PageEvent.where(target_type: Spree::Product)
      product_views = product_page_events.group_by(&:target_id).map do |_id, page_events|
        view = product_view.new(Spree::Product.find_by(id: _id).name)
        view.view_count = page_events.size
        view.user_count = page_events.select(&:actor_id?).uniq(&:actor_id).size
        view.guest_sessions = page_events.reject(&:actor_id?).uniq(&:session_id).size
        view
      end
    end
  end
end
