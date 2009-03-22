require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchObject::Document do
  
  before(:each) do
    @db = mock("CouchObject::Database mock")
    @test_data = {
      "_id" => "123", 
      "_rev" => "666", 
      "foo" => "bar",
      "baz" => {"quux" => [1,2,3]},
    }
    @response = mock("Response mock")
    @response.stub!(:code).and_return(200)
    @response.stub!(:body).and_return("")
    @response.stub!(:to_document).and_return(CouchObject::Document.new(@test_data))
  end
  
  it "should initialize with a bunch of attributes" do
    doc = CouchObject::Document.new({"foo" => "bar"})
    doc.attributes.should == {"foo" => "bar"}
  end
  
  it "should have an id from the attributes" do
    doc = CouchObject::Document.new(@test_data)
    doc.id.should == @test_data["_id"]
  end
  
  it "should not have an id if not in attributes" do
    doc = CouchObject::Document.new
    doc.id.should == nil
  end
  
  it "should have an assignable id if new document" do
    doc = CouchObject::Document.new
    doc.id = "fubar"
    doc.id.should == "fubar"
  end
  
  it "should should be new? if there's an id attribute" do
    doc = CouchObject::Document.new(@test_data)
    doc.new?.should == false
  end
  
  it "should not be new if there's not original id" do
    doc = CouchObject::Document.new({"foo" => "bar"})
    doc.new?.should == true
  end
  
  it "should be Enumerable on its attributes" do
    CouchObject::Document.constants.should include("Enumerator")
    doc = CouchObject::Document.new(@test_data)
    doc.attributes.should_receive(:each)
    doc.map {|attrib| attrib }
  end
  
  it "should be JSONable" do
    doc = CouchObject::Document.new({"foo" => "bar"})    
    doc.to_json.should == JSON.unparse({"foo" => "bar"})
  end
  
  it "should be JSONable and include _id if id= is set" do
    doc = CouchObject::Document.new({"foo" => "bar"})    
    doc.id = "quux"
    doc.to_json.should == JSON.unparse({"foo" => "bar", "_id" => "quux"})
  end
  
  it "should POST to the database with create" do
    doc = CouchObject::Document.new({"foo" => "bar"})    
    @db.should_receive(:post).with("", doc.to_json).and_return(@response)
    doc.save(@db)
  end
  
  it "should PUT to the database with create" do
    doc = CouchObject::Document.new(@test_data)    
    doc.should_receive(:to_json).and_return("JSON")
    @db.should_receive(:put).with(@test_data["_id"], "JSON").and_return(@response)
    doc.save(@db)
  end
  
  it "should send the current revision along when updating a doc" do
    doc = CouchObject::Document.new(@test_data)
    @db.should_receive(:put).and_return(@response)
    doc.should_receive(:to_json).with("_rev" => doc.revision)
    doc.save(@db)
  end
  
  it "should update its id when saving" do
    @test_data.delete("_id")
    @test_data.delete("_rev")
    doc = CouchObject::Document.new(@test_data)
    @db.should_receive(:post).and_return(@response)
    doc.id.should be(nil)
    doc.new?.should == true
    doc.save(@db)
    doc.id.should_not be(nil)
  end
  
  it "should have a revision" do
    doc = CouchObject::Document.new(@test_data)
    doc.revision.should == @test_data["_rev"]    
  end
  
  it "should lookup document attributes with []" do
    doc = CouchObject::Document.new({"foo" => "bar"})
    doc["foo"].should == "bar"
  end
  
  it "should assign document attributes witih []=" do
    doc = CouchObject::Document.new
    doc["foo"].should == nil
    doc["foo"] = "bar"
    doc["foo"].should == "bar"
  end
  
  it "should delegate missing methods to attributes" do
    doc = CouchObject::Document.new({"foo" => "bar", "stuff" => true })
    doc.foo.should == "bar"
    doc.stuff?.should == true
    proc{ doc.foo = "baz" }.should_not raise_error
    doc.foo.should == "baz"
  end
  
  it "should know if it has a given document key" do
    doc = CouchObject::Document.new({"foo" => "bar"})
    doc.has_key?("foo").should == true    
    doc.has_key?("bar").should == false
  end
  
  it "should know if it reponds to a key in the attributes" do
    doc = CouchObject::Document.new({"foo" => "bar", "baz" => true})
    doc.respond_to?(:foo).should == true    
    doc.respond_to?(:bar).should == false
    
    doc.respond_to?(:baz?).should == true    
    doc.respond_to?(:bar?).should == false
    
    doc.respond_to?(:foo=).should == true    
    doc.respond_to?(:bar=).should == false
  end
  
end