Spree::PaymentMethod.class_eval do
  self.whitelisted_ransackable_associations = %w[payments]
  self.whitelisted_ransackable_attributes = %w[created_at]
end
