//= require spree/backend/spree_reportify/paginator
//= require spree/backend/spree_reportify/searcher
//= require spree/backend/spree_reportify/table_sorter

function ReportLoader(inputs) {
  this.$selectList = inputs.reportsSelectBox;
  this.$insightsTableList = inputs.insightsDiv;
  this.requestUrl = '';
  this.isStatePushable = true;
}

ReportLoader.prototype.bindEvents = function() {
  var _this = this;
  _this.$selectList.on('change', function() {
    _this.loadChart($(this).find(':selected'));
  });

  _this.bindPopStateEventCallback();
};

ReportLoader.prototype.bindPopStateEventCallback = function() {
  var _this = this;
  window.onpopstate = function(event) {
    event.state ? (report_name = event.state['report_name'] || '') : (report_name = '')
    _this.$selectList.val(report_name);
    _this.$selectList.select2('val', report_name);
    var $selectedOption = _this.$selectList.find(':selected');
    _this.fetchChartDataWithoutState(location.href, $selectedOption);
  }
};

ReportLoader.prototype.initializeSearcher = function($selectedOption, data) {
  var searcherInputs = {
    filterDiv:   $('#search-div'),
    selectedOption: $selectedOption,
    insightsDiv: this.$insightsTableList,
    tableSorterObject: this.tableSorterObject
  };
  new Searcher(searcherInputs, this).bindEvents(data);
};

ReportLoader.prototype.initializeTableSorter = function() {
  this.tableSorterObject = new TableSorter(this.$insightsTableList, this)
  this.tableSorterObject.bindEvents();
};

ReportLoader.prototype.loadChart = function($selectedOption) {
  var requestPath = $selectedOption.data('url');
  if(requestPath != undefined) {
    this.fetchChartData(requestPath, $selectedOption);
  }
};

ReportLoader.prototype.fetchChartData = function(url, $selectedOption) {
  var _this = this;
  _this.requestUrl = url;
  $.ajax({
    type: 'GET',
    url: url,
    dataType: 'json',
    success: function(data) {
      if(data.headers != undefined) {
        _this.isStatePushable ? _this.populateInsightsData(data) : _this.populateInsightsDataWithoutState(data);
        _this.initializeTableSorter();
        _this.initializeSearcher($selectedOption, data);
        _this.initializePaginator(data);
      } else {
        $('#report-div').empty();
        $('#paginator-div').empty();
      }
    }
  });
}

ReportLoader.prototype.fetchChartDataWithoutState = function(url, $selectedOption) {
  this.isStatePushable = false;
  this.fetchChartData(url, $selectedOption);
}

ReportLoader.prototype.initializePaginator = function(data) {
  var paginatorInputs = {
    paginatorDiv: $('#paginator-div'),
    insightsDiv: this.$insightsTableList,
    reportData: data,
    tableSorterObject: this.tableSorterObject
  };
  new Paginator(paginatorInputs).bindEvents();
};

ReportLoader.prototype.populateInsightsData = function(data) {
  var $templateData = $(tmpl('tmpl', data));
  this.$insightsTableList.empty().append($templateData);
  if(this.isStatePushable) {
    this.pushUrlToHistory();
  } else {
    this.isStatePushable = true;
  }
};

ReportLoader.prototype.populateInsightsDataWithoutState = function(data) {
  this.isStatePushable = false;
  this.populateInsightsData(data);
}

ReportLoader.prototype.pushUrlToHistory = function() {
  var report_name = this.$selectList.find(':selected').val()
  window.history.pushState({ report_name: report_name }, '', this.requestUrl);
};

ReportLoader.prototype.populateInitialData = function() {
  var data = $('div.report-data').data('report-data');
  if(data != null) {
    this.populateInsightsDataWithoutState(data);
  }
};

$(function() {
  var inputs = {
    insightsDiv:      $('#report-div'),
    reportsSelectBox: $('#reports')
  },
    report_loader = new ReportLoader(inputs);
  report_loader.bindEvents();
  report_loader.populateInitialData();
});
