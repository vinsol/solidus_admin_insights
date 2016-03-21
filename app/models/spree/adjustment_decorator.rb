Spree::Adjustment.class_eval do

  delegate :promotion, to: :source

  self.whitelisted_ransackable_attributes = ['created_at']
end
