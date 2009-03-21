class PageVersion <  RelaxDB::Document
  
  property :body, :validator => :required
  property :version, :validator => lambda {|version| version > 0}, :validation_msg => 'Version must not be blank'
  property :page_id, :validator => :required
  
  belongs_to :page
  
  view_by :_id
  
  #default_sort :version
  
end