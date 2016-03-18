module SpreeReportify
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_reportify'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc

    # Overridden since in ransack methods on user are overridden in Spree::Core::Engine.
    # https://github.com/spree/spree/blob/3-0-stable/core/config/initializers/user_class_extensions.rb#L1
    config.after_initialize do
      if Spree.user_class
        Spree.user_class.class_eval do
          def self.ransackable_attributes(auth_object=nil)
            %w[id email created_at]
          end

          def self.ransackable_associations(auth_object=nil)
            %w[bill_address ship_address orders]
          end
        end
      end
    end
  end
end
