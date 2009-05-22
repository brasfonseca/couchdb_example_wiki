var couchapp = null;
$.CouchApp(function(app) {
  couchapp = app;
});
var content = $('#content');


var sammy = $.sammy(function() { with(this) {
  element_selector = '#content';
  
  Wiki.Controllers.Pages(this);
  Wiki.Controllers.PageVersions(this);
  Wiki.Controllers.Statistics(this);
  
  before(function() {
    $('#error').html('').hide();
    $('#notice').html('').hide();
  })
  
  bind('error', function(e, data) { with(this) {
    $('#error').html(data.message).show();
  }});
  
  bind('notice', function(e, data) { with(this) {
    $('#notice').html(data.message).show();
  }});
}});

$(function() {
  sammy.run('#/');
});
