require File.dirname(__FILE__) + '/../spec_helper.rb'
require File.dirname(__FILE__) + "/integration_helper"

describe "Database operations" do
  include IntegrationSpecHelper
  
  before(:each) do
    delete_test_db
  end
  
  it "should create a database " do
    all_dbs = proc{ CouchObject::Database.all_databases("http://localhost:8888") }
    all_dbs.call.include?("couchobject_test").should == false
    
    create_test_db.should == {"ok" => true}
    
    all_dbs.call.include?("couchobject_test").should == true
  end
  
  it "should delete a database" do
    all_dbs = proc{ CouchObject::Database.all_databases("http://localhost:8888") }
    all_dbs.call.include?("couchobject_test").should == false
    
    create_test_db.should == {"ok" => true}
    CouchObject::Database.delete!(
      "http://localhost:8888", 
      "couchobject_test"
    ).should == {"ok" => true}
    
    all_dbs.call.include?("couchobject_test").should == false
  end
  
  it "should open a db connection and know the dbname and uri" do
    db = open_test_db
    db.name.should == "couchobject_test"
    db.url.should == "http://localhost:8888/couchobject_test"
  end
  
  it "should GET a non existing document and return 404" do
    db = open_test_db
    response = db.get("roflcopters")
    response.code.should == 404
  end
  
  it "should POST a new document successfully" do
    db = create_and_open_test_db
    response = db.post("", JSON.unparse({"foo" => ["bar", "baz"]}))
    doc = response.to_document
    doc.ok?.should == true
    doc.id.should_not == nil
  end
  
  it "should PUT to update and existing document" do
    db = create_and_open_test_db
    response = db.post("", JSON.unparse({"foo" => ["bar", "baz"]}))
    created_doc = response.to_document
    response = db.put(created_doc.id, JSON.unparse(
      {"foo" => [1, 2]}.merge("_rev" => created_doc.revision)
    ))
    response.to_document.ok?.should == true
    
    updated_doc = db.get(created_doc.id).to_document
    updated_doc.foo.should == [1,2]
  end
  
  it "should DELETE to delete an existing document" do
    db = create_and_open_test_db
    response = db.post("", JSON.unparse({"foo" => ["bar", "baz"]}))
    created_doc = response.to_document
    
    resp = db.delete(created_doc.id)
    resp.code.should == 202
    
    resp = db.get(created_doc.id)
    resp.code.should == 404
  end
  
  it "should filter documents" do
    db = create_and_open_test_db
    db.post("", JSON.unparse({"foo" => "bar"}))
    db.post("", JSON.unparse({"foo" => "baz"}))
    db.post("", JSON.unparse({"foo" => "qux"}))
    db.all_documents.size.should == 3
    results = db.filter do |doc|
      doc["foo"] =~ /ba/
    end
    results.size.should == 2
    
  end
  
end
