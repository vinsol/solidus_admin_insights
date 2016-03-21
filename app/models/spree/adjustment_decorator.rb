Spree::Adjustment.class_eval do
  self.whitelisted_ransackable_attributes = ['created_at']

  def promotion
    source.try(:promotion)
  end
end
