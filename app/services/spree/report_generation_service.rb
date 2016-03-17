module Spree
  class ReportGenerationService
    REPORTS = {
      product_views: {
        headers: [:product_name, :views, :users, :guest_sessions]
      },
      cart_additions: {
        headers: [:product_name, :additions, :quantity_change]
      },
      cart_removals: {
        headers: [:product_name, :removals, :quantity_change]
      },
      cart_updations: {
        headers: [:product_name, :updations, :quantity_increase, :quantity_decrease]
      },
      product_views_to_cart_additions: {
        headers: [:product_name, :views, :cart_additions]
      }
    }

    def self.product_views(options = {})
      product_view = Struct.new(*REPORTS[:product_views][:headers])
      search = Spree::PageEvent.product_pages.ransack(options[:q])
      product_views = search.result.group_by(&:target_id).map do |_id, page_events|
        view = product_view.new(Spree::Product.find_by(id: _id).name)
        view.views = page_events.size
        view.users = page_events.select(&:actor_id?).uniq(&:actor_id).size
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
        view.updations = cart_events.size
        view.quantity_increase = cart_events.map(&:quantity).select { |quantity| quantity > 0 }.sum
        view.quantity_decrease = cart_events.map(&:quantity).select { |quantity| quantity < 0 }.sum
        view
      end
      [search, cart_additions]
    end

    def self.product_views_to_cart_additions(options = {})
      product_to_cart_view = Struct.new(*REPORTS[:product_views_to_cart_additions][:headers])
      product_views_to_cart_additions = self.product_views(options).second.map do |product_view|
        view = product_to_cart_view.new(product_view.product_name)
        view.views = product_view.views
        view
      end

      self.cart_additions(options).second.each do |cart_addition|
        product_view_cart_addition = product_views_to_cart_additions.find(ifnone = product_to_cart_view.new(cart_addition.product_name, 0)) do |view|
          view.product_name == cart_addition.product_name
        end
        product_view_cart_addition.cart_additions = cart_addition.additions
      end
      [self.product_views(options).first, product_views_to_cart_additions]
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
