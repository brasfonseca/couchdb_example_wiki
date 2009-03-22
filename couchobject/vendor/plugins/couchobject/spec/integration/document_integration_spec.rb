require File.dirname(__FILE__) + '/../spec_helper.rb'
require File.dirname(__FILE__) + "/integration_helper"

describe "Document functionality" do
  include IntegrationSpecHelper
  
  before(:each) do
    delete_test_db
    @db = create_and_open_test_db
  end
  
  it "should create our document" do
    doc = CouchObject::Document.new("foo" => [1,2])
    resp = doc.save(@db)
    resp.code.should == 201
    @db.get(doc.id).code.should == 200
  end
  
  it "should update a document" do
    doc = CouchObject::Document.new("foo" => [1,2])
    resp = doc.save(@db)
    resp.code.should == 201
    
    doc = @db.get(doc.id).to_document
    doc.foo = "bar"
    doc.save(@db).parsed_body["ok"].should == true
    
    doc = @db.get(doc.id).to_document
    doc.foo.should == "bar"
  end
  
  it "should update itself properly" do
    doc = CouchObject::Document.new("foo" => [1,2])
    doc.save(@db)
    @db.all_documents.size.should == 1
    doc.foo = "bar"
    doc.save(@db)
    @db.all_documents.size.should == 1
  end
  
end
