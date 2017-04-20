module SolidusAdminInsights
  class Engine < Rails::Engine
    require 'spree/core'
    require 'sequel'
    require 'wicked_pdf'
    require 'csv'

    isolate_namespace Spree
    engine_name 'solidus_admin_insights'

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
      sequel_config = (
        ActiveRecord::Base.configurations[Rails.env] ||
        Rails.configuration.database_configuration[Rails.env]
      ).to_h.clone
      sequel_config['adapter'] = 'sqlite' if sequel_config['adapter'] == 'sqlite3'
      # Connect to applications DB using ruby's Sequel wrapper
      ::SolidusAdminInsights::ReportDb = Sequel.connect(sequel_config)
    end
  end
end
