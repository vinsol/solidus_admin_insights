Spree::CheckoutController.class_eval do

  include Spree::CheckoutEventTracker

  after_action :track_order_state_change, only: :edit
  after_action :track_order_completion, only: :update, if: :confirm?
  after_action :get_next_state, only: :edit
  after_action :get_previous_state, only: [:edit, :update]

  def track_order_completion
    track_activity(activity: :complete_order, previous_state: @previous_state, next_state: 'complete')
  end

  def track_order_state_change
    unless @previous_state == @next_state
      track_activity(activity: :change_order_state, previous_state: @previous_state, next_state: @next_state)
    end
  end

  def confirm?
    @previous_state == 'confirm'
  end

end
