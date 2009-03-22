require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchObject::Utils do
  
  it "should join urls" do
    CouchObject::Utils.join_url("http://x.tld", "foo").should == "http://x.tld/foo"
    CouchObject::Utils.join_url("http://x.tld", "/foo").should == "http://x.tld/foo"
    CouchObject::Utils.join_url("http://x.tld/", "/foo").should == "http://x.tld/foo"
    CouchObject::Utils.join_url("http://x.tld/", "/foo/").should == "http://x.tld/foo/"
  end
  
  it "should join two or more relative urls too" do
    CouchObject::Utils.join_url("foo", "bar").should == "foo/bar"
    CouchObject::Utils.join_url("foo/", "/bar").should == "foo/bar"
    CouchObject::Utils.join_url("/foo/", "/bar").should == "foo/bar"
    CouchObject::Utils.join_url("/foo/", "/bar/").should == "foo/bar"
  end
end
