class WordCount
  def self.all
    view = RelaxDB::View.new 'word_count', "function(doc) {
      if(doc['relaxdb_class'] == 'Page') {
        var words = doc.body.split(/\\W/);
        words.forEach(function(word) {
          if (word.length > 0) emit(word, 1);
        });
      }
    }",   "function(keys, values) {
        return sum(values);
      }"
    
    view.save unless view.exists?
    
    RelaxDB.view('word_count', :reduce => true, :raw => true, :group => true)['rows'].map{|hash| [hash['key'], hash['value']]}
  end
end