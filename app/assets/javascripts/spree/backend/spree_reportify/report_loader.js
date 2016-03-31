//= require spree/backend/spree_reportify/paginator
//= require spree/backend/spree_reportify/searcher

function ReportLoader(inputs) {
  this.$selectList = inputs.reportsSelectBox;
  this.$insightsTableList = inputs.insightsDiv;
}

ReportLoader.prototype.bindEvents = function() {
  var _this = this;
  this.$selectList.on('change', function() {
    _this.loadChart($(this).find(':selected'));
  });
};

ReportLoader.prototype.initializeSearcher = function($selectedOption, data) {
  var searcherInputs = {
    filterDiv:   $('#search-div'),
    selectedOption: $selectedOption,
    insightsDiv: this.$insightsTableList
  };
  new Searcher(searcherInputs).bindEvents(data);
};

ReportLoader.prototype.loadChart = function($selectedOption) {
  var requestPath = $selectedOption.data('url'),
    _this = this;
  $.ajax({
    type: 'GET',
    url: requestPath,
    dataType: 'json',
    success: function(data) {
      _this.populateInsightsData(data);
      _this.initializePaginator(data);
      _this.initializeSearcher($selectedOption, data);
    }
  });
};

ReportLoader.prototype.initializePaginator = function(data) {
  var paginatorInputs = {
    paginatorDiv: $('#paginator-div'),
    insightsDiv: this.$insightsTableList,
    reportData: data
  };
  new Paginator(paginatorInputs).bindEvents();
};

ReportLoader.prototype.populateInsightsData = function(data) {
  var $templateData = $(tmpl('tmpl', data));
  this.$insightsTableList.empty().append($templateData);
};

$(function() {
  var inputs = {
    insightsDiv:      $('#report-div'),
    reportsSelectBox: $('#reports')
  };
  new ReportLoader(inputs).bindEvents();
});
