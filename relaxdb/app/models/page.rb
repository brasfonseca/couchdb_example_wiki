class Page < RelaxDB::Document
  
  after_save :create_version
  
  property :title, :validator => :required
  property :body, :validator => :required
  property :created_at
  
  #default_sort :created_at
  
  has_many :page_versions, :class => 'PageVersion' #, :order => :version
  
  view_by :title
  view_by :created_at
  
  def errors
    _errors = super
    def _errors.count
      self.size
    end
    _errors
  end
  
  def body_with_keep_old=(new_body)
    @body_was ||= body
    self.send :'body_without_keep_old=', new_body
  end
  alias_method_chain :body=, :keep_old
  
  private
  
  def create_version
    version = PageVersion.new(:body => @body_was, :version => page_versions.size + 1)
    page_versions << version || raise("page version not saved: #{version.errors.inspect}") if @body_was
  end
  

end