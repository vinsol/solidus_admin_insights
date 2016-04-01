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

  var attribute, sortOrder;
    attribute = this.getSortedAttribute('asc');
  if (this.$insightsTableList.find('.asc').length) {
    sortOrder = 'asc';
  } else if(this.$insightsTableList.find('.desc').length) {
    attribute = this.getSortedAttribute('desc');
    sortOrder = 'desc';
  }
  var $element = $(event.target),
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


Paginator.prototype.getSortedAttribute = function(order) {
  if (this.$insightsTableList.find(`.${order}`).length > 0) {
    return this.$insightsTableList.find(`.${order}`).html().toLowerCase().split(' ').join('_');
  } else {
    return null;
  }
};
