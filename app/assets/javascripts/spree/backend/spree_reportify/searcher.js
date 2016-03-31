//= require spree/backend/spree_reportify/paginator

function Searcher(inputs) {
 this.$insightsTableList = inputs.insightsDiv;
 this.$filters = inputs.filterDiv;
 this.$quickSearchForm = this.$filters.find('#quick-search');
 this.$selectedInsight = inputs.selectedOption;
 this.tableSorter = inputs.tableSorterObject;
}

Searcher.prototype.bindEvents = function(data) {
 var requestPath = this.$selectedInsight.data('url'),
   _this = this;
 this.$filters.removeClass('hide');
 this.addSearchForm(data);
 this.setFormActions(this.$quickSearchForm, requestPath);
 this.setFormActions(this.$filterForm, requestPath);

 this.$filterForm.on('submit', function() {
   _this.addSearchStatus();
   $.ajax({
     type: "GET",
     url: _this.$filterForm.attr('action'),
     data: _this.$filterForm.serialize(),
     dataType: 'json',
     success: function(data) {
       _this.clearFormFields();
       _this.populateInsightsData(data);
       _this.initializePaginator(data);
     }
   });
   return false;
 });

 this.$quickSearchForm.on('submit', function() {
   $.ajax({
     type: "GET",
     url:  _this.$quickSearchForm.attr('action'),
     data: _this.$filterForm.serialize(),
     dataType: 'json',
     success: function(data) {
       _this.populateInsightsData(data);
       _this.initializePaginator(data);
     }
   });
   return false;
 });

 $(document).on("click", ".js-delete-filter", function() {
   $('#quick_search').val('');
   $(this).parent().hide();
 });
};

Searcher.prototype.addSearchStatus = function () {
 var filtersContainer = $(".js-filters");
 filtersContainer.empty();
 $(".js-filterable").each(function() {
   var $this = $(this);

   if ($this.val()) {
     var ransack_value, filter;
     var ransack_field = $this.attr("id");
     var label = $('label[for="' + ransack_field + '"]');

     if ($this.is("select")) {
       ransack_value = $this.find('option:selected').text();
     } else {
       ransack_value = $this.val();
     }

     label = label.text() + ': ' + ransack_value;
     filter = '<span class="js-filter label label-default" data-ransack-field="' + ransack_field + '">' + label + '<span class="icon icon-delete js-delete-filter"></span></span>';

     filtersContainer.append(filter).show();
   }
 });
};

Searcher.prototype.addSearchForm = function(data) {
 this.$filters.find('#table-filter').empty().append($(tmpl('search-tmpl', data)));
 this.$filterForm = this.$filters.find('#filter-search');
 $('.datepicker').datepicker({ dateFormat: 'yy-mm-dd' });
};

Searcher.prototype.setFormActions = function($form, path) {
 $form.attr("method", "get");
 $form.attr("action", path);
};

Searcher.prototype.populateInsightsData = function(data) {
 var $templateData = $(tmpl('tmpl', data));
 this.$insightsTableList.empty().append($templateData);
 this.tableSorter.bindEvents();
};

Searcher.prototype.initializePaginator = function(data) {
 var paginatorInputs = {
   paginatorDiv: $('#paginator-div'),
   insightsDiv: this.$insightsTableList,
   reportData: data,
   tableSorterObject: this.tableSorter
 };
 new Paginator(paginatorInputs).bindEvents();
};

Searcher.prototype.clearFormFields = function() {
 $('.filter-well').slideUp();
};
