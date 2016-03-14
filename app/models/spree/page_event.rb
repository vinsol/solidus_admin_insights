module Spree
  class PageEvent < Spree::Base
    belongs_to :actor, polymorphic: true
    belongs_to :object, polymorphic: true
  end
end
