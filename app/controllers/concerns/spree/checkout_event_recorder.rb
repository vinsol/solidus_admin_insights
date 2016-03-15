module Spree
  module CheckoutEventRecorder

    extend ActiveSupport::Concern

    def create_tracker_entry(attributes)
      default_attributes = { referrer: request.referrer, actor: spree_current_user, object: @order }
      Spree::Checkout::Event::Tracker.new(default_attributes.merge(attributes)).track
    end

  end
end
