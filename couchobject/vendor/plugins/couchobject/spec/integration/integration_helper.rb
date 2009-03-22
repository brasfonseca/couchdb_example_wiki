require File.dirname(__FILE__) + '/../spec_helper.rb'

module IntegrationSpecHelper
  def create_test_db(name="couchobject_test")
    CouchObject::Database.create!("http://localhost:8888", name)
  end
  
  def open_test_db(name="couchobject_test")
    CouchObject::Database.open("http://localhost:8888/#{name}")    
  end
  
  def delete_test_db(name="couchobject_test")
    CouchObject::Database.delete!("http://localhost:8888", "couchobject_test")
  end
  
  def create_and_open_test_db(name="couchobject_test")
    create_test_db(name)
    open_test_db(name)
  end
end