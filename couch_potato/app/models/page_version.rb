class PageVersion
  
  include CouchPotato::Persistence
  
  property :body
  property :version
  property :page_id
  
  view :by_page_id, :key => :page_id
  view :by_page_id_and_version, :key => [:page_id, :version]
  
  validates_presence_of :body, :page_id, :version
  

end