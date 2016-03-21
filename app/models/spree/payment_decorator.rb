Spree::Payment.class_eval do
  self.whitelisted_ransackable_attributes = %w[state created_at]
end
