module Spree
  class CheckoutEvent < Spree::Base

    with_options polymorphic: true do
      belongs_to :actor
      belongs_to :object
    end

    validates :object, :session_id, :activity, presence: true

  end
end
