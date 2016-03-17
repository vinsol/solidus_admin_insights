module Spree
  class ReportGenerationService
    REPORTS = {
      product_views: { headers: [:product_name, :view_count, :user_count, :guest_sessions] },
      cart_additions: { headers: [:product_name, :addition_count, :quantity_change] },
      cart_removals: { headers: [:product_name, :removal_count, :quantity_change] },
      cart_updations: { headers: [:product_name, :updation_count, :quantity_increase, :quantity_decrease] }
    }

    def self.product_views
      product_view = Struct.new(*REPORTS[:product_views][:headers])
      product_page_events = Spree::PageEvent.where(target_type: Spree::Product)
      product_views = product_page_events.group_by(&:target_id).map do |_id, page_events|
        view = product_view.new(Spree::Product.find_by(id: _id).name)
        view.view_count = page_events.size
        view.user_count = page_events.select(&:actor_id?).uniq(&:actor_id).size
        view.guest_sessions = page_events.reject(&:actor_id?).uniq(&:session_id).size
        view
      end
    end

    def self.cart_additions
      cart_based_events(:cart_additions, :add)
    end

    def self.cart_removals
      cart_based_events(:cart_removals, :remove)
    end

    def self.cart_updations
      cart_additions_view = Struct.new(*REPORTS[:cart_updations][:headers])
      cart_additions = Spree::CartEvent.events(:update).group_by(&:product).map do |product, cart_events|
        view = cart_additions_view.new(product.name)
        view.updation_count = cart_events.count
        view.quantity_increase = cart_events.map(&:quantity).select { |quantity| quantity > 0 }.sum
        view.quantity_decrease = cart_events.map(&:quantity).select { |quantity| quantity < 0 }.sum
        view
      end
    end

    class << self
      private
        def cart_based_events(report_type, event_type)
          cart_additions_view = Struct.new(*REPORTS[report_type][:headers])
          cart_additions = Spree::CartEvent.events(event_type).group_by(&:product).map do |product, cart_events|
            view = cart_additions_view.new(product.name)
            view[REPORTS[report_type][:headers].second] = cart_events.count
            view.quantity_change = cart_events.map(&:quantity).sum
            view
          end
        end
    end
  end
end
