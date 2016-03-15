module Spree
  class CartEvent < Spree::Base
    with_options polymorphic: true do
      belongs_to :actor
      belongs_to :object
    end

    validates :activity,
              :actor,
              :object,
              :quantity,
              :total, presence: true
  end
end
