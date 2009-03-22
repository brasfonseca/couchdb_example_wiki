require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchObject::Database do
  before(:each) do
    @server = mock("Couch server")
    @uri = "http://localhost:8888"
    @response = mock("Net::HTTP::Response")
    CouchObject::Server.should_receive(:new).with(@uri).and_return(@server)
    @response.stub!(:code).and_return(200)
    @response.stub!(:body).and_return("[\"db1\", \"db2\"]")
    @document_response = {
      "_id" => "123BAC", 
      "_rev" => "946B7D1C", 
      "attributes" => {
        "wheels" => 3
      }
    }
  end
  
  it "should create a database" do
    @server.should_receive(:put).with("/foo", "").and_return(@response)
    CouchObject::Database.create!(@uri, "foo")
  end
  
  it "should delete a database" do
    @server.should_receive(:delete).with("/foo").and_return(@response)
    CouchObject::Database.delete!(@uri, "foo")
  end
  
  it "should get all databases" do
    @server.should_receive(:get).with("/_all_dbs").and_return(@response)
    CouchObject::Database.all_databases(@uri)
  end
  
  it "should return all databases as an array" do
    @server.should_receive(:get).with("/_all_dbs").and_return(@response)
    dbs = CouchObject::Database.all_databases(@uri)
    dbs.should == ["db1", "db2"]
  end
  
  it "should open a connection to the server" do
    db = CouchObject::Database.new(@uri, "foo")
    db.server.should == @server
  end
  
  it "should have a name" do
    db = CouchObject::Database.new(@uri, "foo")
    db.name.should == "foo"    
  end
  
  it "should lint the database name from slashes with ::open" do
    db = CouchObject::Database.open("http://localhost:8888/foo")
    class << db
      attr_accessor :dbname
    end
    db.dbname.should == "foo"
  end
  
  it "should GET" do
    db = CouchObject::Database.new(@uri, "foo")    
    @server.should_receive(:get).with("/foo/123").and_return(@response)
    db.get("123")
  end
  
  it "should POST" do
    db = CouchObject::Database.new(@uri, "foo")        
    @server.should_receive(:post).with("/foo/123", "postdata").and_return(@response)
    db.post("123", "postdata")
  end
  
  it "should PUT" do
    db = CouchObject::Database.new(@uri, "foo")        
    @server.should_receive(:put).with("/foo/123", "postdata").and_return(@response)
    db.put("123", "postdata")
  end
  
  it "should DELETE" do
    db = CouchObject::Database.new(@uri, "foo")        
    @server.should_receive(:delete).with("/foo/123").and_return(@response)
    db.delete("123")
  end
  
  it "should open a new connection from a full uri spec" do
    proc{ CouchObject::Database.open("http://localhost:8888/foo") }.should_not raise_error
  end
  
  it "should know the database name" do
    db = CouchObject::Database.new(@uri, "foo")
    db.name.should == "foo"    
  end
  
  it "should know the full uri" do
    db = CouchObject::Database.new(@uri, "foo")
    db.url.should == "http://localhost:8888/foo"    
  end
  
  it "should load a document from id with #[]" do
    db = CouchObject::Database.new(@uri, "foo")
    db.should_receive(:get).with("123").twice.and_return(@document_response)
    proc{ db["123"] }.should_not raise_error
    db["123"].should == @document_response
  end
  
  it "should accept symbols for #[] too" do
    db = CouchObject::Database.new(@uri, "foo")
    db.should_receive(:get).with("foo").and_return(@document_response)
    db[:foo]
  end
  
  it "should get a document by id" do
    db = CouchObject::Database.new(@uri, "foo")
    db.should_receive(:get).with("foo").twice.and_return(@document_response)
    proc{ db.document("foo") }.should_not raise_error
    db.document("foo").should == @document_response
  end
  
  it "should get a document by id and revision" do
    db = CouchObject::Database.new(@uri, "foo")
    db.should_receive(:get).with("foo?rev=123").twice.and_return(@document_response)
    proc{ db.document("foo", "123") }.should_not raise_error
    db.document("foo", "123").should == @document_response
  end
  
  it "should query the view" do
    db = CouchObject::Database.new(@uri, "foo")
    CouchObject::View.should_receive(:new).with(db, "myview").and_return(view = mock("View mock"))
    view.should_receive(:query).and_return(nil)
    db.views("myview")
  end
  
  it "should get a list of all documents" do
    db = CouchObject::Database.new(@uri, "foo")
    resp = mock("response")
    resp.stub!(:body).and_return(JSON.unparse("rows" => [{"_rev"=>123, "_id"=>"123ABC"}]))
    resp.stub!(:to_document).and_return(
      CouchObject::Document.new("rows" => [{"_rev"=>123, "_id"=>"123ABC"}])
    )
    db.should_receive(:get).with("_all_docs").and_return(resp)
    db.all_documents.should == [{"_rev"=>123, "_id"=>"123ABC"}]
  end
  
  it "should store a document" do
    db = CouchObject::Database.new(@uri, "foo")
    doc = CouchObject::Document.new({"foo" => "bar"})
    db.should_receive(:post).with("", JSON.unparse("foo" => "bar"))
    db.store(doc)
  end
  
  it "should return the rows when filtering" do
    db = CouchObject::Database.new(@uri, "foo")
    rowdata = { "_rev"=>1,
                "_id"=>"1",
                "value"=> {
                  "_id"=>"1",
                  "_rev"=>1,
                  "foo"=>"bar"
                }
              }
    resp = mock("response")
    resp.stub!(:body).and_return(JSON.unparse("rows" => [rowdata]))
    resp.stub!(:parse).and_return(resp)
    resp.stub!(:to_document).and_return(
      CouchObject::Document.new("rows" => [rowdata])
    )
    db.should_receive(:post).with("_temp_view", "proc { |doc|\n (doc[\"foo\"] == \"bar\")\n}").and_return(resp)
    rows = db.filter{|doc| doc["foo"] == "bar"}
    rows.size.should == 1
    rows.first["value"]["foo"].should == "bar"
  end
  
  #it "should url encode paths"
end