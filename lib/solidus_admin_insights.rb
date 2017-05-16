require 'spree_core'
require 'solidus_admin_insights/engine'

module SolidusAdminInsights
  class Config
    def self.configure
      yield configuration if block_given?
    end

    def self.configuration
      @config ||= Spree::Report::Configuration.new
    end
  end
end
