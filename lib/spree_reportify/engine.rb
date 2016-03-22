module SpreeReportify
  class Engine < Rails::Engine
    require 'spree/core'
    require 'sequel'

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

    config.after_initialize do
      # Overridden since in ransack methods on user are overridden in Spree::Core::Engine.
      # https://github.com/spree/spree/blob/3-0-stable/core/config/initializers/user_class_extensions.rb#L1
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

      # Connect to applications DB using ruby's Sequel wrapper
      ::SpreeReportify::ReportDb = Sequel.connect(Rails.configuration.database_configuration[Rails.env])
    end
  end
end
