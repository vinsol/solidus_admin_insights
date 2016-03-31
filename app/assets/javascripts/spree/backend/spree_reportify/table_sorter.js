//= require spree/backend/jquery.tablesorter.min

function TableSorter($insightsTable) {
  this.$insightsTableList = $insightsTable;
}

TableSorter.prototype.bindEvents = function() {
  var _this = this;
  this.$sortableLinks = this.$insightsTableList.find('#admin-insight .sortable-link');
  this.$sortableLinks.on('click', function() {
    event.preventDefault();
    var requestPath = $(event.target).attr('href');

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
  var $templateData = $(tmpl('tmpl', data));
  this.$insightsTableList.empty().append($templateData);
  this.bindEvents();
};
