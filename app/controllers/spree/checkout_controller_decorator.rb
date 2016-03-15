Spree::CheckoutController.class_eval do

  include Spree::CheckoutEventTracker

  after_action :track_order_state_change, only: :edit
  after_action :track_order_completion, only: :update, if: :confirm?

  def track_order_completion
    track_activity(activity: :complete_order, previous_state: get_previous_state, next_state: 'complete')
  end

  def track_order_state_change
    next_state = request.url.split('/').last
    unless get_previous_state == next_state
      track_activity(activity: :change_order_state, previous_state: get_previous_state, next_state: next_state)
    end
  end

  def get_previous_state
    request.referrer ? request.referrer.split('/').last : nil
  end

  def confirm?
    get_previous_state == 'confirm'
  end

end
