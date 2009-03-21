require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/spec_models.rb'

describe RelaxDB::Query do
  
  before(:all) do
    RelaxDB.configure :host => "localhost", :port => 5984, :design_doc => ""
  end

  describe "#view_name" do

    it "should match a single key attribute" do
      q = RelaxDB::ViewCreator.by_att_list ["bar"], :foo
      q.view_name.should == "bar_by_foo"
    end
    
    it "should match key attributes" do
      q = RelaxDB::ViewCreator.by_att_list ["bar"], :foo, :bar
      q.view_name.should == "bar_by_foo_and_bar"
    end
  end
  
  describe "#view_path" do
    
    it "should list design document and view name and default reduce to false" do
      q = RelaxDB::Query.new("mount")
      q.view_path.should == "_view//mount?reduce=false"
    end
    
    it "should contain URL and JSON encoded key when the key has been set" do
      q = RelaxDB::Query.new("")
      q.key("olympus")
      q.view_path.should == "_view//?key=%22olympus%22&reduce=false"
    end
    
    it "should honour startkey, endkey and limit" do
      q = RelaxDB::Query.new("")
      q.startkey(["olympus"]).endkey(["vesuvius", 3600]).limit(100)
      q.view_path.should == "_view//?startkey=%5B%22olympus%22%5D&endkey=%5B%22vesuvius%22%2C3600%5D&limit=100&reduce=false"
    end
        
    it "should specify a null key if key was set to nil" do
      q = RelaxDB::Query.new("")
      q.key(nil)
      q.view_path.should == "_view//?key=null&reduce=false"
    end

    it "should specify a null startkey if startkey was set to nil" do
      q = RelaxDB::Query.new("")
      q.startkey(nil)
      q.view_path.should == "_view//?startkey=null&reduce=false"
    end

    it "should specify a null endkey if endkey was set to nil" do
      q = RelaxDB::Query.new("")
      q.endkey(nil)
      q.view_path.should == "_view//?endkey=null&reduce=false"
    end
    
    it "should not JSON encode the startkey_docid" do
      q = RelaxDB::Query.new("")
      q.startkey_docid("foo")
      q.view_path.should == "_view//?startkey_docid=foo&reduce=false"
    end

    it "should not JSON encode the endkey_docid" do
      q = RelaxDB::Query.new("")
      q.endkey_docid("foo")
      q.view_path.should == "_view//?endkey_docid=foo&reduce=false"
    end
    
  end  
  
  describe "#keys" do
    
    it "should return a JSON encoded hash" do
      q = RelaxDB::Query.new("")
      q.keys(["a", "b"])
      q.keys.should == '{"keys":["a","b"]}'
    end
    
  end
      
end
