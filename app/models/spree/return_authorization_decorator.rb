Spree::ReturnAuthorization.class_eval do
  has_many :variants, through: :inventory_units
  has_many :products, through: :variants
end
