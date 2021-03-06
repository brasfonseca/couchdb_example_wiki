class Page < CouchRest::ExtendedDocument
  include CouchRest::Validation
  include ActiveSupport::Callbacks
  
  define_callbacks :update
  update_callback :after, :create_version
  
  use_database COUCH_DB
  
  property :title
  property :body
  
  timestamps!
  
  view_by :title
  view_by :created_at
  
  validates_present :title, :body
  
  def versions(options = {})
    PageVersion.by_version_and_page_id({:startkey => [1, self.id], :endkey => [9999999999, self.id]}.merge(options))
  end
  
  def versions_count
    versions(:reduce => true)['rows'].first.try(:[], 'value') || 0
  end
  
  def errors
    _errors = super
    def _errors.count
      self.size
    end
    _errors
  end
  
  def self.word_counts
    WordCount.by_count(:reduce => true, :group => true)['rows'].map{|row| [row['key'], row['value']]}
  end
  
  def body_with_keep_old=(new_body)
    @body_was ||= body
    self.send :'body_without_keep_old=', new_body
  end
  alias_method_chain :body=, :keep_old
  
  private
  
  def create_version
    PageVersion.new(:page_id => id, :body => @body_was, :version => versions_count + 1).save!
    true
  end
  
end