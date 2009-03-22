function(doc, req) {
  // !code lib/helpers/template.js
  // !code vendor/couchapp/path.js
  // !json lib.templates
  
  return template(lib.templates["new"], {
    assets : assetPath()
  });
  
  
};