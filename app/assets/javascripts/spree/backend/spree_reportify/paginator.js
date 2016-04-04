function Paginator(inputs, reportLoader) {
  this.$insightsTableList = inputs.insightsDiv;
  this.paginatorDiv = inputs.paginatorDiv;
  this.tableSorter = inputs.tableSorterObject;
  this.reportLoader = reportLoader;
}

Paginator.prototype.bindEvents = function () {
  var _this = this;
  this.paginatorDiv.on('click', '.pagination-link', function (event) {
    event.preventDefault();
    _this.loadPaginationData(event);
  });
  this.reportLoader.pageSelector.on('change', function(event) {
    _this.loadReportData(event);
  });
};

Paginator.prototype.refreshPaginator = function(data) {
  this.reportLoader.pageSelector.val(data['per_page']);
  this.populatePaginationData(data);
};

Paginator.prototype.loadPaginationData = function (event) {
  var $element = $(event.target),
    sorted_attributes = this.tableSorter.fetchSortedAttribute(),
    attribute = sorted_attributes[0],
    sortOrder = sorted_attributes[1],
    requestPath = `${$element.attr('href')}&sort%5Battribute%5D=${attribute}&sort%5Btype%5D=${sortOrder}`,
    _this = this;
  _this.reportLoader.requestUrl = requestPath;

  if (!($element.parents('li').hasClass('active'))) {
    $.ajax({
      type: 'GET',
      url: requestPath,
      dataType: 'json',
      success: function(data) {
        _this.populateInsightsData(data);
        _this.paginatorDiv.find('.active').removeClass('active');
        $element.parents('li').addClass('active');
      }
    });
  }
};

Paginator.prototype.populateInsightsData = function(data) {
  this.reportLoader.populateInsightsData(data);
};

Paginator.prototype.populatePaginationData = function(data) {
  var $templateData = $(tmpl('paginator-tmpl', data));
  this.paginatorDiv.empty().append($templateData);
  this.pageLinks = this.paginatorDiv.find('.pagination-link');
};

Paginator.prototype.loadReportData = function(event) {
  var $element = $(event.target),
      sorted_attributes = this.tableSorter.fetchSortedAttribute(),
      attribute = sorted_attributes[0],
      sortOrder = sorted_attributes[1],
      requestUrl = `${$element.data('url')}&sort%5Battribute%5D=${attribute}&sort%5Btype%5D=${sortOrder}&${$('#filter-search').serialize()}&per_page=${$element.val()}`;
  $element.data('url', requestUrl);
  this.reportLoader.loadChart($element);
};
