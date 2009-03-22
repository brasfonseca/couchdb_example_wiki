require File.dirname(__FILE__) + '/spec_helper.rb'

class Bike
  include CouchObject::Persistable
  
  def initialize
    @wheels = 2
  end
  attr_accessor :wheels
  
  def to_couch
    {:wheels => @wheels}
  end
  
  def self.from_couch(attributes)
    bike = new
    bike.wheels = attributes["wheels"]
    bike
  end
end

describe CouchObject::Persistable, "when mixed into a Class" do
  before(:each) do
    @bike = Bike.new
    @db = mock("mock db")
    
    @empty_response = {}    
    @ok_response = {"ok" => true}
    @document_response = {
      "_id" => "123BAC", 
      "_rev" => "946B7D1C", 
      "attributes" => {
        "wheels" => 3
      }
    }
  end
  
  it "should give the class a save method that saves the object" do
    CouchObject::Database.should_receive(:open).and_return(@db)
    @db.should_receive(:post).with("", @bike.to_json).and_return(@empty_response)
    @bike.save("foo")
  end
  
  it "should raise if no to_couch on class" do
    klass = Class.new{ include CouchObject::Persistable }
    proc{ klass.new.to_json }.should raise_error(CouchObject::Persistable::NoToCouchMethodError)
  end
  
  it "should raise if no to_couch on class" do
    klass = Class.new{ 
      include CouchObject::Persistable 
      def to_couch() end
    }
    proc{ klass.get_by_id("foo", "bar") }.should raise_error(CouchObject::Persistable::NoFromCouchMethodError)
  end
  
  it "should return the doc id on successfull save" do
    CouchObject::Database.should_receive(:open).and_return(@db)
    @db.should_receive(:post).with("", @bike.to_json).and_return(@document_response)
    @bike.save("foo")["_id"].should == "123BAC"
  end  
  
  it "should assign the returned id to itself on successful save" do
    CouchObject::Database.should_receive(:open).and_return(@db)
    @db.should_receive(:post).with("", @bike.to_json).and_return(@document_response)
    @bike.save("foo")
    @bike.id.should == "123BAC"
  end
  
  it "should know if itself is a new object" do
    CouchObject::Database.should_receive(:open).and_return(@db)
    @db.should_receive(:post).with("", @bike.to_json).and_return(@document_response)
    @bike.new?.should == true
    @bike.save("foo")
    @bike.new?.should == false
  end
  
  it "should get document by id" do
    CouchObject::Database.should_receive(:open).and_return(@db)
    @db.should_receive(:get).with("123BAC").and_return(@document_response)
    Bike.get_by_id("foo", "123BAC")
  end
  
  it "should instantiate a new object based on their #to_couch" do
    CouchObject::Database.should_receive(:open).and_return(@db)
    @db.should_receive(:get).with("123BAC").and_return(@document_response)
    bike = Bike.get_by_id("foo", "123BAC")
    bike.class.should == Bike
    bike.wheels.should == 3
  end
end