Spree::BaseHelper.class_eval do
  def selected?(current_insight, insight)
    current_insight.eql?(insight)
  end

  def form_action(insight, insight_type)
    insight ? admin_insight_path(id: @report_name, type: insight_type) : 'javascript:void(0)'
  end
end
