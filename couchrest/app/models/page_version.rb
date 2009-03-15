class PageVersion < CouchRest::ExtendedDocument
  include CouchRest::Validation
  
  use_database COUCH_DB
  
  property :body
  property :version
  property :page_id
  
  timestamps!
  
  view_by :page_id
  view_by :version, :page_id
  
  
  validates_present :body, :page_id, :version
  
  
end