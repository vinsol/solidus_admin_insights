module Spree
  class PageEvent < Spree::Base

    with_options polymorphic: true do
      belongs_to :actor
      belongs_to :target
    end

    validates :referrer, :session_id, :activity, presence: true

  end
end
