Spree::OrdersController.class_eval do

  include ::Spree::CheckoutEventRecorder

  after_action :track_return_to_cart, only: :edit, if: :current_order
  after_action :track_empty_cart_activity, only: :empty

  def track_empty_cart_activity
    previous_state = request.referrer.split('/').last
    create_tracker_entry(activity: 'empty_cart', previous_state: previous_state, next_state: nil)
  end


  def track_return_to_cart
    state = request.referrer.split('/').last
    if !current_order.checkout_steps.include?(state) && state != 'cart'
      activity = 'initialize_order'
    else
      activity = 'return to cart'
    end
    previous_state = (current_order.checkout_steps.include?(state) || state == 'cart') ? state : nil
    next_state = request.url.split('/').last
    unless previous_state == next_state
      create_tracker_entry(activity: activity, previous_state: previous_state, next_state: next_state)
    end
  end

end
