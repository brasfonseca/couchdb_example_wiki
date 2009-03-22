class PageVersion < CouchRest::ExtendedDocument
  include CouchRest::Validation
  
  use_database COUCH_DB
  
  property :body
  property :version
  property :page_id
  
  timestamps!
  
  view_by :page_id
  view_by :version, :page_id, :map => "function(doc) {if(doc['couchrest-type'] == 'PageVersion') {emit([doc.version, doc.page_id], 1)}}", :reduce => "function(keys, values) {
    return sum(values);
  }"
  
  
  validates_present :body, :page_id, :version
  
  
end