var couchapp = null;
$.CouchApp(function(app) {
  couchapp = app;
});
var content = $('#content');

var sammy = $.sammy(function() { with(this) {
  element_selector = '#content';
  
  get('#/', function() { with(this) {
    couchapp.design.view("pages_by_created_at", {
       limit: 1,
       success: function(json) {
         if(json.rows[0]) {
           redirect('#/pages/show/' + json.rows[0]['id']);
           content.html();
         } else {
           redirect('#/pages/new');
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
  
  get('#/pages/show/:id', function() { with(this) {
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
  
  get('#/pages/new', function() { with(this) {
    partial('./templates/pages/new.html.erb');
  }});
  
  
  
  post('#/pages', function() { with(this) {
    var page = {
      title: params['title'],
      body: params['body'],
      created_at: Date(),
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
    };
    if(page.valid()) {
      couchapp.db.saveDoc(page.to_json(), {
        success: function(res) {
          trigger('notice', {message: 'Page Saved'});
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
