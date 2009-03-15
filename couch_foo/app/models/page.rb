class Page < CouchFoo::Base
  
  after_save :create_version
  
  property :title, String
  property :body, String
  property :created_at, DateTime
  
  default_sort :created_at
  
  validates_presence_of :title, :body
  
  has_many :page_versions, :order => :version
  
  def versions
    page_versions
  end
  
  def self.word_counts
    result = begin
      database.view 'word_count/words', :group => true
    rescue CouchFoo::DocumentNotFound
      database.save({
        "_id" => "_design/word_count",
        :views => {
          :words => word_count_views
        }
      })
      retry
    end
    p result
    result['rows'].map{|row| [row['key'], row['value']]}
  end
  
  private
  
  def create_version
    page_versions.create!(:body => body_was, :version => page_versions.size + 1) unless body_was.nil? || !body_changed?
  end
  
  def self.word_count_views
    {
      :map => "function(doc) {
        if(doc.ruby_class == 'Page') {
          var words = doc.body.split(/\\W/);
          words.forEach(function(word) {
            if (word.length > 0) emit(word, 1);
          });
        }
      }",
      :reduce => "function(key, combine) {
        return sum(combine);
      }"
    }
  end

end