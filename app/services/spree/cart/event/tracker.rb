module Spree
  module Cart
    module Event
      class Tracker < Spree::Event::Tracker

        def initialize(arguments: {})
          super(arguments)
          @quantity = arguments[:quantity]
          @total = arguments[:total]
        end

        def track
          CartEvent.create(attributes)
        end
      end
    end
  end
end
