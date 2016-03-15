module Spree
  module CheckoutEventTracker
    extend ActiveSupport::Concern

    def track_activity(attributes)
      default_attributes = { referrer: request.referrer,
                             actor: spree_current_user,
                             object: @order,
                             session_id: session.id }
      Spree::Checkout::Event::Tracker.new(default_attributes.merge(attributes)).track
    end

  end
end
