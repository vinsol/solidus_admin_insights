Spree::ProductsController.class_eval do
  after_action :track_event, only: :show

  private
    def track_event
      Spree::Page::Event::Tracker.new(
        activity: Spree::Page::Event::Tracker::EVENTS[action_name.to_sym],
        referrer: request.referrer,
        actor: current_spree_user,
        object: instance_variable_get("@#{ controller_name.singularize }")
      ).track
    end
end
