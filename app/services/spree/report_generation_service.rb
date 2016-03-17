module Spree
  class ReportGenerationService
    REPORTS = {
      product_views: { headers: [:product_name, :view_count, :user_count, :guest_sessions] },
      cart_additions: { headers: [:product_name, :addition_count, :quantity_change] },
      cart_removals: { headers: [:product_name, :removal_count, :quantity_change] },
      cart_updations: { headers: [:product_name, :updation_count, :quantity_increase, :quantity_decrease] }
    }

    def self.product_views(options = {})
      product_view = Struct.new(*REPORTS[:product_views][:headers])
      search = Spree::PageEvent.where(target_type: Spree::Product).ransack(options[:q])
      product_views = search.result.group_by(&:target_id).map do |_id, page_events|
        view = product_view.new(Spree::Product.find_by(id: _id).name)
        view.view_count = page_events.size
        view.user_count = page_events.select(&:actor_id?).uniq(&:actor_id).size
        view.guest_sessions = page_events.reject(&:actor_id?).uniq(&:session_id).size
        view
      end
      [search, product_views]
    end

    def self.cart_additions(options = {})
      cart_based_events(:cart_additions, :add, options)
    end

    def self.cart_removals(options = {})
      cart_based_events(:cart_removals, :remove, options)
    end

    def self.cart_updations(options = {})
      cart_additions_view = Struct.new(*REPORTS[:cart_updations][:headers])
      search = Spree::CartEvent.events(:update).ransack(options[:q])
      cart_additions = search.result.group_by(&:product).map do |product, cart_events|
        view = cart_additions_view.new(product.name)
        view.updation_count = cart_events.size
        view.quantity_increase = cart_events.map(&:quantity).select { |quantity| quantity > 0 }.sum
        view.quantity_decrease = cart_events.map(&:quantity).select { |quantity| quantity < 0 }.sum
        view
      end
      [search, cart_additions]
    end

    class << self
      private
        def cart_based_events(report_type, event_type, options = {})
          cart_additions_view = Struct.new(*REPORTS[report_type][:headers])
          search = Spree::CartEvent.events(event_type).ransack(options[:q])
          cart_additions = search.result.group_by(&:product).map do |product, cart_events|
            view = cart_additions_view.new(product.name)
            view[REPORTS[report_type][:headers].second] = cart_events.size
            view.quantity_change = cart_events.map(&:quantity).sum
            view
          end
          [search, cart_additions]
        end
    end
  end
end
