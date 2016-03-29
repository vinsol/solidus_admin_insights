function ReportLoader(inputs) {
  this.$selectList = inputs.reportsSelectBox;
  this.$insightsTableList = inputs.insightsDiv;
  this.$filters = inputs.filterDiv;
  this.$quickSearchForm = this.$filters.find('#quick-search');
  this.$filterForm = this.$filters.find('#filter-search');
}

ReportLoader.prototype.bindEvents = function() {
  var _this = this;
  this.$selectList.on('change', function() {
    _this.loadChart($(this).find(':selected'));
    return false;
  });
  this.$filterForm.on('submit', function() {
    event.preventDefault();
    $.ajax({
      type: "GET",
      url: _this.$filterForm.attr('action'),
      data: _this.$filterForm.serialize(),
      dataType: 'json',
      success: function(data) {
        _this.populateInsightsData(data);
      }
    });
  });
  this.$quickSearchForm.on('submit', function() {
    event.preventDefault();
    $.ajax({
      type: "GET",
      url:  _this.$quickSearchForm.attr('action'),
      data: _this.$quickSearchForm.serialize(),
      dataType: 'json',
      success: function(data) {
        _this.populateInsightsData(data);
      }
    });
  });
};

ReportLoader.prototype.loadChart = function($selected_option) {
  var requestPath = $selected_option.data('url'),
    _this = this;
  $.ajax({
    type: 'GET',
    url: requestPath,
    dataType: 'json',
    success: function(data) {
      _this.populateInsightsData(data);
      _this.$filters.removeClass('hide');
      _this.setFormActions(_this.$quickSearchForm, requestPath);
      _this.setFormActions(_this.$filterForm, requestPath);
    }
  });
};

ReportLoader.prototype.setFormActions = function($form, path) {
  $form.attr("method", "get");
  $form.attr("action", path);
};

ReportLoader.prototype.populateInsightsData = function(data) {
  var $templateData = $(tmpl('tmpl', data));
  this.$insightsTableList.empty().append($templateData);
};

$(function() {
  var inputs = {
    reportsSelectBox:  $('#reports'),
    insightsDiv:       $('#report-div'),
    filterDiv:         $('#search-div')
  };
  new ReportLoader(inputs).bindEvents();
});
