Spree::BaseHelper.class_eval do
  def selected?(current_type, tab_type)
    current_type == tab_type
  end
end
