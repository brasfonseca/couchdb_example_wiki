class PageVersion < ActiveCouch::Base
  include Validatable
  
  validates_presence_of :body, :page_id, :version

  site YAML::load(File.open(File.join(Rails.root,
                    'config', 'activecouch.yml')))[Rails.env]['site']
  
  has :body
  has :version
  has :page_id
  has :created_at
  
  # view_by :page_id
  #   view_by :version, :page_id, :map => "function(doc) {if(doc['couchrest-type'] == 'PageVersion') {emit([doc.version, doc.page_id], 1)}}", :reduce => "function(keys, values) {
  #     return sum(values);
  #   }"
  
  
  
end