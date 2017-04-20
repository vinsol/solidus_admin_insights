//= require spree/backend/solidus_admin_insights/paginator

function Searcher(inputs, reportLoader) {
  this.$insightsTableList = inputs.insightsDiv;
  this.$filters = inputs.filterDiv;
  this.$quickSearchForm = this.$filters.find('#quick-search');
  this.tableSorter = inputs.tableSorterObject;
  this.reportLoader = reportLoader;
  this.$filterForm = null;
  this.$searchLabelsContainer = this.$filters.find('.table-active-filters');
}

Searcher.prototype.bindEvents = function(data) {
  var _this = this;
  this.$searchLabelsContainer.on("click", ".js-delete-filter", function() {
    _this.$quickSearchForm[0].reset();
    $(this).parent().hide();
  });
};

Searcher.prototype.refreshSearcher = function($selectedInsight, data) {
  var requestPath = $selectedInsight.data('url'),
    _this = this;

  _this.$filters.removeClass('hide');
  _this.addSearchForm(data);
  _this.setFormActions(_this.$quickSearchForm, requestPath);
  _this.setFormActions(_this.$filterForm, requestPath);

  _this.$filterForm.on('submit', function() {
   var noPagination = _this.reportLoader.removePaginationButton.closest('span').hasClass('hide');
   $.ajax({
     type: "GET",
     url: _this.$filterForm.attr('action'),
     data: _this.$filterForm.serialize() + "&per_page=" + _this.reportLoader.pageSelector.find(':selected').attr('value') + '&no_pagination=' + noPagination,
     dataType: 'json',
     success: function(data) {
      _this.reportLoader.requestUrl = this.url;
      _this.populateInsightsData(data);
      _this.reportLoader.paginatorObject.refreshPaginator(data);
     }
   });
   return false;
  });
};

Searcher.prototype.addSearchForm = function(data) {
  this.$filters.find('#table-filter').empty().append($(tmpl('search-tmpl', data)));
  this.$filterForm = this.$filters.find('#filter-search');
  this.$filters.find('.datepicker').datepicker({ dateFormat: 'yy-mm-dd' });
};

Searcher.prototype.setFormActions = function($form, path) {
  $form.attr("method", "get");
  $form.attr("action", path);
};

Searcher.prototype.populateInsightsData = function(data) {
  this.reportLoader.populateInsightsData(data);
};

Searcher.prototype.fillFormFields = function(searchedFields) {
  $.each(Object.keys(searchedFields), function() {
    $('#search_' + this).val(searchedFields[this]);
  });
};

Searcher.prototype.clearSearchFields = function() {
  this.$quickSearchForm[0].reset();
  var filtersContainer = $(".js-filters");
  filtersContainer.empty();
};
