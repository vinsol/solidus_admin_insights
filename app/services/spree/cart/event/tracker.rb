module Spree
  module Cart
    module Event
      class Tracker < Spree::Event::Tracker

        def initialize(arguments: {})
          super(arguments)
          @quantity = arguments[:quantity]
          @total = arguments[:total]
        end
      end
    end
  end
end
