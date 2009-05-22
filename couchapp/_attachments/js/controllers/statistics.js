Wiki.Controllers.Statistics = function(sammy) { with(sammy) {
  get('#/statistics', function() { with(this) {
    var context = this;
    couchapp.design.view('statistics', {
      group: true,
      success: function(json) {
        context.partial('./templates/statistics/index.html.erb', function(html) {
          content.html(html);
          this.each(json['rows'], function(i, row) {
            this.partial('./templates/statistics/_stat.html.erb', {stat: row}, function(stat_html) {
              $(stat_html).appendTo('#statistics')
            });
          });
        });
      }
    })
  }});
}}