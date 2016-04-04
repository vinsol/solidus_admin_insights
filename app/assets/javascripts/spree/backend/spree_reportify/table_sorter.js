//= require spree/backend/jquery.tablesorter.min

function TableSorter($insightsTable, reportLoader) {
  this.$insightsTableList = $insightsTable;
  this.reportLoader = reportLoader;
}

TableSorter.prototype.bindEvents = function() {
  var _this = this;
  this.$insightsTableList.on('click', '#admin-insight .sortable-link', function() {
    event.preventDefault();
    var currentPage = $('#paginator-div li.active a').html() - 1
    var requestPath = $(event.target).attr('href') + '&' + $('#filter-search').serialize() + '&page=' + currentPage + "&per_page=" + _this.reportLoader.pageSelector.find(':selected').attr('value');
    _this.reportLoader.requestUrl = requestPath;

    $.ajax({
      type: 'GET',
      url: requestPath,
      dataType: 'json',
      success: function(data) {
        _this.populateInsightsData(data);
      }
    });
  });
};

TableSorter.prototype.populateInsightsData = function(data) {
  this.reportLoader.populateInsightsData(data);
};

TableSorter.prototype.fetchSortedAttribute = function() {
  var attribute, sortOrder;
  if (this.$insightsTableList.find('.asc').length) {
    attribute = this.getSortedAttribute('asc');
    sortOrder = 'asc';
  } else if(this.$insightsTableList.find('.desc').length) {
    attribute = this.getSortedAttribute('desc');
    sortOrder = 'desc';
  }
  return [attribute, sortOrder];
};

TableSorter.prototype.getSortedAttribute = function(order) {
  return this.$insightsTableList.find(`.${order}`).html().toLowerCase().split(' ').join('_');
};
