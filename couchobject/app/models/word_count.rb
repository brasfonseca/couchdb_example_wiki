class WordCount < CouchRest::ExtendedDocument
  
  use_database COUCH_DB
  
  view_by :count, :map => "function(doc) {
    if(doc['couchrest-type'] == 'Page') {
      var words = doc.body.split(/\\W/);
      words.forEach(function(word) {
        if (word.length > 0) emit(word, 1);
      });
    }
  }",
  :reduce => "function(keys, values) {
    return sum(values);
  }"
end