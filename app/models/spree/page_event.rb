module Spree
  class PageEvent < Spree::Base

    with_options polymorphic: true do
      belongs_to :actor
      belongs_to :target
    end

    validates :activity,
              :session_id, presence: true

    scope :product_pages, -> { where(target_type: Spree::Product) }

    self.whitelisted_ransackable_attributes = ['created_at']
  end
end
