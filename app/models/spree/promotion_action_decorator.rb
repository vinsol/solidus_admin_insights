Spree::PromotionAction.class_eval do
  has_one :adjustment, -> { promotion }, class_name: 'Spree::Adjustment', foreign_key: :source_id
end
