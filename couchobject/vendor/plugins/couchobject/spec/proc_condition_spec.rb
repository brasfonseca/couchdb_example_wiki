require File.dirname(__FILE__) + '/spec_helper.rb'

describe CouchObject::ProcCondition do
  
  it "should accept a block only" do
    proc{ 
      CouchObject::ProcCondition.new do |x|
        x
      end
    }.should_not raise_error
  end
  
  it "should require a block argument" do
    proc{ 
      CouchObject::ProcCondition.new do
        "bar"
      end
    }.should raise_error(ArgumentError)
  end
  
  it "should convert itself to ruby" do
    CouchObject::ProcCondition.new do |x|
      x
    end.to_ruby.should == "proc { |x|\n x\n}"
  end
end