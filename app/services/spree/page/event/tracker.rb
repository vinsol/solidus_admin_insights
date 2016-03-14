module Spree
  module Page
    module Event
      class Tracker < Spree::Event::Tracker
        EVENTS = { show: :view, search: :search, filter: :filter }

        def track
          PageEvent.create(instance_values)
        end
      end
    end
  end
end
