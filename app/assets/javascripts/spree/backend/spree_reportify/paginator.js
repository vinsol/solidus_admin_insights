function Paginator(inputs) {
  this.$insightsTableList = inputs.insightsDiv;
  this.reportData = inputs.reportData;
  this.paginatorDiv = inputs.paginatorDiv;
}

Paginator.prototype.bindEvents = function () {
  var _this = this;
  this.populatePaginationData(this.reportData);
  this.pageLinks.on('click', function (event) {
    event.preventDefault();
    _this.loadPaginationData(event);
  });
};

Paginator.prototype.loadPaginationData = function (event) {
  var requestPath = $(event.target).attr('href'),
    _this = this;
  $.ajax({
    type: 'GET',
    url: requestPath,
    dataType: 'json',
    success: function(data) {
      _this.populateInsightsData(data);
    }
  });
};

Paginator.prototype.populateInsightsData = function(data) {
  var $templateData = $(tmpl('tmpl', data));
  this.$insightsTableList.empty().append($templateData);
};

Paginator.prototype.populatePaginationData = function(data) {
  var $templateData = $(tmpl('paginator-tmpl', data));
  this.paginatorDiv.empty().append($templateData);
  this.pageLinks = $('.pagination-link');
};
