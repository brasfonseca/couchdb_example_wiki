require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchObject::View do

  before(:each) do
    @server = mock("CouchObject::Server mock")
    @db = CouchObject::Database.open("http://localhost:8888/foo")
    @db.server = @server
    @js = "function(doc){ return doc }"
    @response = mock("Net::HTTP::Response")
    @response.stub!(:code).and_return(200)
    @response.stub!(:body).and_return(%Q'{"view":"_foo_view:#{@js}","total_rows":0,"rows":[]}')
  end
  
  it "should create a new views" do
    @db.should_receive(:post).with("/foo/_view_myview", @js).and_return(@response)
    CouchObject::View.create(@db, "myview", @js)    
  end
  
  it "should initialzie with db and name and have a view name" do
    view = CouchObject::View.new(@db, "myview")
    view.name.should == "_view_myview"
    view.db.should == @db
  end
  
  it "should delete a view" do
    view = CouchObject::View.new(@db, "myview")
    @db.should_receive(:delete).with("/foo/_view_myview").and_return(true)
    view.delete
  end
  
  # it "should query the database with itself"
  # it "should have a ::query singleton for temp view queries"
  # it "should iterate over the results"
  # 
end