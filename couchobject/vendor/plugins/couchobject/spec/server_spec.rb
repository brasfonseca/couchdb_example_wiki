require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchObject::Server do
  
  it "should initialize with a URI" do
    server = CouchObject::Server.new("http://localhost:8888")
    server.host.should == "localhost"
    server.port.should == 8888
  end
  
  it "should have a connection active when its initialized" do
    server = CouchObject::Server.new("http://localhost:8888")
    server.connection.should_not be(nil)    
    server.connection.class.should == Net::HTTP
  end
  
  it "should dispatch requests" do
    server = CouchObject::Server.new("http://localhost:8888")
    request = mock(Net::HTTP::Get)
    server.connection.should_receive(:request).with(request).and_return("response")
    server.request(request)
  end  
end

describe CouchObject::Server, "Request methods" do
  before(:each) do
    @server = CouchObject::Server.new("http://localhost:8888")
    @mock_request = mock("Net::HTTP::{requestmethod}")
  end
  
  it "should have GET" do
    Net::HTTP::Get.should_receive(:new).with("/foo").and_return(@mock_request)
    @server.connection.should_receive(:request).with(@mock_request).and_return("response")
    @server.get("/foo")
  end
  
  it "should have POST" do
    Net::HTTP::Post.should_receive(:new).with("/foo").and_return(@mock_request)
    @mock_request.should_receive(:body=).with("bar")
    @mock_request.stub!(:[]=)
    @server.connection.should_receive(:request).with(@mock_request).and_return("response")
    @server.post("/foo", "bar")
  end
  
  it "should have PUT" do
    Net::HTTP::Put.should_receive(:new).with("/foo").and_return(@mock_request)
    @mock_request.should_receive(:body=).with("bar")
    @mock_request.stub!(:[]=)
    @server.connection.should_receive(:request).with(@mock_request).and_return("response")
    @server.put("/foo", "bar")
  end
  
  it "should have DELETE" do
    Net::HTTP::Delete.should_receive(:new).with("/foo").and_return(@mock_request)
    @server.connection.should_receive(:request).with(@mock_request).and_return("response")
    @server.delete("/foo")
  end
  
  it "should POST with application/json as the Content-Type header" do
    Net::HTTP::Post.should_receive(:new).with("/foo").and_return(@mock_request)
    @mock_request.stub!(:body=)
    @mock_request.should_receive(:[]=).with("content-type", "application/json")
    @server.connection.should_receive(:request).with(@mock_request).and_return("response")
    @server.post("/foo", "bar")
  end
  
  it "should PUT with application/json as the Content-Tyoe header" do
    Net::HTTP::Put.should_receive(:new).with("/foo").and_return(@mock_request)
    @mock_request.stub!(:body=)
    @mock_request.should_receive(:[]=).with("content-type", "application/json")
    @server.connection.should_receive(:request).with(@mock_request).and_return("response")
    @server.put("/foo", "bar")
  end
end