class WordCount
  def self.all
    self.new.all
  end
  
  def all
    begin
     JSON.parse(connection.get(view_path))['rows'].map{|hash| [hash['key'], hash['value']]}
    rescue ActiveCouch::ResourceNotFound => e
      p e
      create_view
      retry
    end
  end
  
  private
  
  def view_path
    '/pages/_design/statistics/_view/word_counts?group=true&reduce=true'
  end
  
  def create_view
    connection.put '/pages/_design/statistics', {:views => {
      'word_counts' => {
        'map' => "function(doc) {
            if(doc.body) {
              var words = doc.body.split(/\\W/);
              words.forEach(function(word) {
                if (word.length > 0) emit(word, 1);
              });
            }
          }",
        'reduce' => "function(keys, values) {
          return sum(values
          );
        }"
      }
    }}.to_json
  end
  
  def connection
    Page.connection
  end
  
  
end

