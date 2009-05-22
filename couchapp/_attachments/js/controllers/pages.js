Wiki.Controllers.Pages = function(sammy) { with(sammy) {
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
        redirect("#/new_page?title=" + params['id']);
      }
    });
  }});
  
  get('#/pages/:id/edit', function() { with(this) {
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
    var parseHashParams = function(hash) {
      var matches = hash.match(/\?(\w+=\w+&?)+/);
      if(matches) {
        matches.shift();
        var params_array = matches.map(function(m) {return m.split('=')});
        var hash_params = {};
        for(var i in params_array) {
          hash_params[params_array[i][0]] = params_array[i][1];
        }
        return hash_params;
      } else {
        return {};
      }
    }
    var hash_params = parseHashParams(location.hash);
    title = hash_params.title;
    partial('./templates/pages/new.html.erb');
  }});
  
  put('#/pages/:id', function() { with(this) {
    couchapp.db.openDoc(params['id'], {
      success: function(doc) {
        var page = Wiki.Models.Page.init(doc);
        page.body = params['body'];
        if(page.valid()) {
          couchapp.db.saveDoc(page.to_json(), {
            success: function(res) {
              page.after_update(couchapp.db);
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
      },
      error: function() {
        trigger('error', {message: "Page not found"});
      }
    });
    return false;
  }});
  
  post('#/pages', function() { with(this) {
    var page = Wiki.Models.Page.init(params);
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
}}