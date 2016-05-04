Deface::Override.new(virtual_path: 'spree/admin/shared/_menu',
  name: 'add_insights_to_admin_side_menu',
  insert_bottom: "[data-hook='admin_tabs']",
  partial: 'spree/admin/shared/insights_side_menu',
)
