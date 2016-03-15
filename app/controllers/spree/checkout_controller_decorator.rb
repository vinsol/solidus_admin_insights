Spree::CheckoutController.class_eval do

  include ::Spree::CheckoutEventRecorder

  after_action :track_order_state_change, only: :edit
  after_action :track_order_completion, only: :update

  def track_order_completion
    previous_state = request.referrer.split('/').last
    if previous_state == 'confirm'
      create_tracker_entry(activity: 'complete_order', previous_state: previous_state, next_state: 'complete')
    end
  end

  def track_order_state_change
    previous_state = request.referrer.split('/').last
    next_state = request.url.split('/').last
    unless previous_state == next_state
      create_tracker_entry(activity: 'change_order_state', previous_state: previous_state, next_state: next_state)
    end
  end

end
