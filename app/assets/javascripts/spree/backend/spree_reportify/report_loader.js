function ReportLoader($select_list) {
  this.$select_list = $select_list;
};

ReportLoader.prototype.bindEvents = function() {
  var _this = this;
  _this.$select_list.on('change', function() {
    _this.load_chart($(this).find(':selected'));
  });
};

ReportLoader.prototype.load_chart = function($selected_option) {
  $.ajax({
    type: 'GET',
    url: $selected_option.data('url'),
    dataType: 'json',
    success: function(data) {
      var $templateData = $(tmpl('tmpl', data));
      $('#report-div').empty().append($templateData);
    }
  });
};

$(function(){
  new ReportLoader($('#reports')).bindEvents();
})
