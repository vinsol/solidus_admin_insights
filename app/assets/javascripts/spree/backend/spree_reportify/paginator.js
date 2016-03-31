function Paginator(inputs) {
  this.$insightsTableList = inputs.insightsDiv;
  this.reportData = inputs.reportData;
  this.paginatorDiv = inputs.paginatorDiv;
  this.tableSorter = inputs.tableSorterObject;
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
  var $element = $(event.target),
    requestPath = $element.attr('href'),
    _this = this;

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
  var $templateData = $(tmpl('tmpl', data));
  this.$insightsTableList.empty().append($templateData);
};

Paginator.prototype.populatePaginationData = function(data) {
  var $templateData = $(tmpl('paginator-tmpl', data));
  this.paginatorDiv.empty().append($templateData);
  this.pageLinks = this.paginatorDiv.find('.pagination-link');
};
