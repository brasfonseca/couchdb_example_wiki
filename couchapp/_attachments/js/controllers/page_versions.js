Wiki.Controllers.PageVersions = function(sammy) { with(sammy) {
  get('#/pages/:page_id/versions', function() { with(this) {
    var context = this;
    couchapp.db.openDoc(params['page_id'], {
      success: function(doc) {
        context.page = doc;
        couchapp.design.view('page_versions_by_page_id_and_created_at', {
          startkey: [params['page_id'], null],
          include_docs: true,
          success: function(json) {
            context.page_versions = json.rows;
            context.partial('./templates/page_versions/index.html.erb', function(html) {
               content.html(html);
               this.each(json['rows'], function(i, page_version) {
                 this.partial('./templates/page_versions/_page_version.html.erb', {page_version: page_version.doc}, function(page_html) {
                   $(page_html).appendTo('#page_versions')
                 });
               });
             });
          }
        });
      },
      error: function() {
        trigger('error', {message: "Page not found"});
      }
    });
  }});
  
  get('#/pages/:page_id/versions/:id', function() { with(this) {
    var context = this;
    couchapp.db.openDoc(params['page_id'], {
      success: function(doc) {
        context.page = doc;
        couchapp.db.openDoc(context.params['id'], {
          success: function(json) {
            context.page_version = json;
            context.partial('./templates/page_versions/show.html.erb');
          }
        });
      },
      error: function() {
        trigger('error', {message: "Page not found"});
      }
    });
  }});
}}