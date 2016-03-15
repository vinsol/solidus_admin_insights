module Spree
  class CartEvent < Spree::Base
    belongs_to :actor, polymorphic: true
    belongs_to :object, polymorphic: true
  end
end
