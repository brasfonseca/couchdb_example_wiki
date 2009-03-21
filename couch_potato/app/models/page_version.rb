class PageVersion
  
  include CouchPotato::Persistence
  
  property :body
  property :version
  property :page_id
  
  belongs_to :page
  
  validates_presence_of :body
  

end