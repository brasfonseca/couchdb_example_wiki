var couchapp = null;
$.CouchApp(function(app) {
  couchapp = app;
});
var content = $('#content');

var Wiki = {
  Page: {
    init: function(attributes) {
      this.id = attributes.id;
      this._rev = attributes._rev;
      this.title = attributes.title;
      this.body = attributes.body;
      this.created_at = attributes.created_at || Date();
      return this;
    },
    errors: [],
    valid: function() {
      this.errors = [];
      if(this.title.length == 0) {
        this.errors.push("Title can't be blank");
      }
      if(this.body.length == 0) {
        this.errors.push("Body can't be blank");
      }
      return this.errors.length == 0;
    },
    to_json: function() {
      return {
        title: this.title,
        body: this.body,
        created_at: this.created_at,
        type: 'Page'
      }
    }
  }
};

var sammy = $.sammy(function() { with(this) {
  element_selector = '#content';
  
  get('#/', function() { with(this) {
    couchapp.design.view("pages_by_created_at", {
       limit: 1,
       success: function(json) {
         if(json.rows[0]) {
           redirect('#/pages/' + json.rows[0]['id']);
           content.html();
         } else {
           redirect('#/new_page');
         }
       }
     });
  }});
  
  get('#/pages', function() { with(this) {
    var context = this;
    couchapp.design.view("pages_by_created_at", {
       include_docs: true,
       success: function(json) {
         context.partial('./templates/pages/index.html.erb', function(html) {
           content.html(html);
           this.each(json['rows'], function(i, page) {
             this.partial('./templates/pages/_page.html.erb', {page: page.doc}, function(page_html) {
               $(page_html).appendTo('#all_pages')
             })
             
           });
         });
       }
     });
  }});
  
  get('#/pages/:id', function() { with(this) {
    var context = this;
    couchapp.db.openDoc(params['id'], {
      success: function(doc) {
        context.page = doc;
        context.partial('./templates/pages/show.html.erb')
      },
      error: function() {
        trigger('error', {message: "Page not found"});
      }
    });
  }});
  
  get('#/pages/edit/:id', function() { with(this) {
    var context = this;
    couchapp.db.openDoc(params['id'], {
      success: function(doc) {
        context.page = doc;
        context.partial('./templates/pages/edit.html.erb')
      },
      error: function() {
        trigger('error', {message: "Page not found"});
      }
    });
  }});
  
  get('#/new_page', function() { with(this) {
    partial('./templates/pages/new.html.erb');
  }});
  
  post('#/pages/:id', function() { with(this) {
    var page = Wiki.Page.init(params);
    if(page.valid()) {
      couchapp.db.saveDoc(page.to_json(), {
        success: function(res) {
          trigger('notice', {message: 'Page Saved'});
          redirect('#/pages/' + res.id)
        },
        error: function(response_code, res) {
          trigger('error', {message: 'Error saving page: ' + res});
        }
      });
    } else {
      trigger('error', {message: page.errors.join(", ")});
    };
    return false;
  }});
  
  post('#/pages', function() { with(this) {
    var page = Wiki.Page.init(params);
    if(page.valid()) {
      couchapp.db.saveDoc(page.to_json(), {
        success: function(res) {
          trigger('notice', {message: 'Page Saved'});
          redirect('#/pages/' + res.id)
        },
        error: function(response_code, res) {
          trigger('error', {message: 'Error saving page: ' + res});
        }
      });
    } else {
      trigger('error', {message: page.errors.join(", ")});
    };
    return false;
  }});
  
  get('#/statistics', function() { with(this) {
    var context = this;
    couchapp.design.view('statistics', {
      group: true,
      success: function(json) {
        context.partial('./templates/pages/statistics.html.erb', function(html) {
          content.html(html);
          this.each(json['rows'], function(i, row) {
            this.partial('./templates/pages/_stat.html.erb', {stat: row}, function(stat_html) {
              $(stat_html).appendTo('#statistics')
            });
          });
        });
      }
    })
  }});
  
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
