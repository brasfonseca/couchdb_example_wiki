class Page
  
  include CouchPotato::Persistence
  # include CouchPotato::Versioning LETS CALL IT PROBLEMATIC
  
  after_update :create_version
  
  property :title
  property :body
  
  #default_sort :created_at
  
  validates_presence_of :title, :body
  
  has_many :page_versions
  
  def self.word_counts
    counts = ViewQuery.new('statictics', 'word_counts', "function(doc) {
        if(doc.ruby_class == 'Page') {
          var words = doc.body.split(/\\W/);
          words.forEach(function(word) {
            if (word.length > 0) emit(word, 1);
          });
        }
      }", "function(key, combine) {
          return sum(combine);
        }", {}, {:group => true}).query_view!
    counts['rows'].map{|row| [row['key'], row['value']]}
  end
  
  private
  
  def create_version
    page_versions.create!(:body => body_was, :version => page_versions.size + 1) unless !body_changed?
  end
  

end