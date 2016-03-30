//= require spree/backend/jquery.tablesorter.min

function TableSorter($insightsTable) {
  this.$insightsTableList = $insightsTable;
}

TableSorter.prototype.bindEvents = function() {
  this.$insightsTableList.find('#admin-insight').tablesorter();
};
