Spree::BaseHelper.class_eval do
  def selected?(path)
    path == 'spree/admin/insights'
  end

  def form_action(insight, insight_type)
    insight ? admin_insight_path(id: @report_name, type: insight_type) : 'javascript:void(0)'
  end

  def page_selector_options
    [5, 10, 15, 30, 45, 60]
  end

  def pdf_logo(image_path = Spree::Config[:logo])
    wicked_pdf_image_tag image_path, class: 'logo'
  end
end
