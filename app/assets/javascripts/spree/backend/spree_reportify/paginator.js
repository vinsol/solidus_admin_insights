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
};

Paginator.prototype.refreshPaginator = function(data) {
  this.populatePaginationData(data);
};

Paginator.prototype.loadPaginationData = function (event) {
  var $element = $(event.target),
    requestPath = $element.attr('href'),
    _this = this;
  _this.reportLoader.requestUrl = requestPath;

  if (!($element.parents('li').hasClass('active'))) {
    $.ajax({
      type: 'GET',
      url: requestPath,
      dataType: 'json',
      success: function(data) {
        _this.populateInsightsData(data);
        _this.tableSorter.bindEvents();
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
