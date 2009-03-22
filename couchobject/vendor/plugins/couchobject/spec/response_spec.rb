require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchObject::Response do
  before(:each) do
    @net_response = mock("Net::HTTP::Response")
    @net_response.stub!(:code).and_return(200)
    @net_response.stub!(:body).and_return("{\"foo\":\"bar\"}")
  end
  
  it "should get the response code" do
    resp = CouchObject::Response.new(@net_response)
    resp.code.should == 200
  end
  
  it "should know if the response was a success" do
    resp = CouchObject::Response.new(@net_response)
    resp.success?.should == true
  end
  
  it "should have the body of the response" do    
    resp = CouchObject::Response.new(@net_response)
    resp.body.should == "{\"foo\":\"bar\"}"
  end
  
  it "should parse the response" do
    @net_response.stub!(:body).and_return("[\"foo\", \"bar\"]")    
    resp = CouchObject::Response.new(@net_response)
    resp.parse.parsed_body.should == ["foo", "bar"]
  end
  
  it "should  parse the response body even if error" do
    @net_response.stub!(:code).and_return(404)
    resp = CouchObject::Response.new(@net_response)
    resp.parse.parsed_body.should == {"foo" => "bar"}
  end
  
  it "should return itself when calling parse" do
    resp = CouchObject::Response.new(@net_response)
    resp.parse.should be_instance_of(CouchObject::Response)
  end
  
  it "should return its body as a Document with to_document" do
    resp = CouchObject::Response.new(@net_response)
    resp.to_document.should be_instance_of(CouchObject::Document)    
    resp.to_document["foo"].should == "bar"
  end
end