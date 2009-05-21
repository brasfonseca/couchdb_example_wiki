class Page
  
  include CouchPotato::Persistence
  
  before_update :create_version
  
  property :title
  property :body
  
  validates_presence_of :title, :body
  
  view :by_title, :key => :title
  view :by_created_at, :key => :created_at
  view :word_counts,
    :type => :raw, :map => "function(doc) {
      if(doc.ruby_class == 'Page') {
        var words = doc.body.split(/\\W/);
        words.forEach(function(word) {
          if (word.length > 0) emit(word, 1);
        });
      }
    }",
    :reduce =>   "function(key, values) {
            return sum(values);
          }",
    :group => true,
    :results_filter => lambda {|res| res['rows'].map{|row| [row['key'], row['value']]}}
  
  
  def new_record?
    new?
  end
  
  private
  
  def create_version(db)
    new_version = db.view(PageVersion.by_page_id(:key => _id, :reduce => true)) + 1
    db.save! PageVersion.new(:body => body_was, :version => new_version, :page_id => _id) if body_changed?
  end
  

end