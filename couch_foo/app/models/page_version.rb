class PageVersion < CouchFoo::Base
  
  property :body, String
  property :version, Integer
  property :page_id, String
  
  belongs_to :page
  
  default_sort :version
  
  
  validates_presence_of :body, :page_id, :version
  
  
end