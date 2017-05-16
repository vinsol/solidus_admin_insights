REPORT_TABS = [:insights, *Spree::ReportGenerationService.reports.keys.collect(&:to_sym)]

Spree::Backend::Config.configure do |config|
  config.menu_items << config.class::MenuItem.new(
    REPORT_TABS,
    'bar-chart',
    condition: ->{ can?(:display, :insights) },
    partial: 'spree/admin/shared/insights_side_menu'
  )
end

Spree::RoleConfiguration.configure do |config|
  config.assign_permissions :admin, [Spree::PermissionSets::InsightDisplay]
end
