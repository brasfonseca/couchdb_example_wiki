class Page < CouchFoo::Base
  
  after_save :create_version
  
  property :title, String
  property :body, String
  property :created_at, DateTime
  
  default_sort :created_at
  
  validates_presence_of :title, :body
  
  has_many :page_versions, :order => :version
  
  
  view :word_count,   "function(doc) {
      if(doc.ruby_class == 'Page') {
        var words = doc.body.split(/\\W/);
        words.forEach(function(word) {
          if (word.length > 0) emit(word, 1);
        });
      }
    }", "function(key, combine) {
        return sum(combine);
      }", :group => true, :return_json => true
  
  def versions
    page_versions
  end
  
  def self.word_counts
    word_count['rows'].map{|row| [row['key'], row['value']]}
  end
  
  private
  
  def create_version
    page_versions.create!(:body => body_was, :version => page_versions.size + 1) unless body_was.nil? || !body_changed?
  end
  

end