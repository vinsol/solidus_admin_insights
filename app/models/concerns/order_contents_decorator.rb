module Spree
  module OrderContentsWithTracker

    def update_cart(params)
      if order.update_attributes(filter_order_items(params))
        order.line_items.select(&:changed?).each do |line_item|
          if line_item.previous_changes.keys.include?('quantity')
            previous_quantity_changes = line_item.previous_changes[:quantity]
            changed_quantity = changed_quantity(previous_quantity_changes)
            Spree::Cart::Event::Tracker.new(
              activity: activity(changed_quantity, line_item, options = {}),
              actor: order,
              object: line_item,
              quantity: changed_quantity,
              total: order.total
            ).track
          end
        end
        order.line_items = order.line_items.select { |li| li.quantity > 0 }
        persist_totals
        PromotionHandler::Cart.new(order).activate
        order.ensure_updated_shipments
        persist_totals
        true
      else
        false
      end
    end

    private

    def after_add_or_remove(line_item, options = {})
      line_item = super(line_item, options = {})
      previous_quantity_changes = line_item.previous_changes[:quantity]
      changed_quantity = changed_quantity(previous_quantity_changes)
      Spree::Cart::Event::Tracker.new(activity: options[:line_item_created] ? :add : activity(changed_quantity, line_item, options = {}),
        actor: order, object: line_item, quantity: changed_quantity, total: order.total).track
      line_item
    end

    def changed_quantity(previous_quantity_changes)
      previous_quantity_changes.last.to_i - previous_quantity_changes.first.to_i
    end

    def activity(changed_quantity, line_item, options = {})
      if (changed_quantity > 0 && changed_quantity == line_item.quantity)
        :add
      elsif (changed_quantity < 0 && line_item.quantity == 0)
        :remove
      elsif changed_quantity
        :update
      end
    end
  end
end

Spree::OrderContents.send(:prepend, Spree::OrderContentsWithTracker)
