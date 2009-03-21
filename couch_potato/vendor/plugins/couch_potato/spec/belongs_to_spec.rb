require File.dirname(__FILE__) + '/spec_helper'

describe 'belongs_to' do
  before(:all) do
    CouchPotato::Persistence.Db!
  end
  
  before(:each) do
    @commenter = Commenter.create!
  end
  
  it "should return nil by default" do
    c = Comment.new :title => 'title'
    c.commenter.should be_nil
    c.commenter_id.should be_nil
  end
  
  it "should assign the parent object" do
    c = Comment.new :title => 'title'
    c.commenter = @commenter
    c.commenter.should == @commenter
    c.commenter_id.should == @commenter.id
  end
  
  it "should assign the parent object id" do
    c = Comment.new :title => 'title'
    c.commenter_id = @commenter.id
    c.commenter.should == @commenter
    c.commenter_id.should == @commenter.id
  end
  
  it "should unassign the parent object" do
    c = Comment.new :title => 'title', :commenter => stub('comenter', :id => 1)
    c.commenter = nil
    c.commenter.should be_nil
    c.commenter_id.should be_nil
  end
  
  it "should unassign the parent object id" do
    c = Comment.new :title => 'title', :commenter => stub('comenter', :id => 1)
    c.commenter_id = nil
    c.commenter.should be_nil
    c.commenter_id.should be_nil
  end
  
  it "should persist the link to the parent object" do
    c = Comment.new :title => 'title'
    c.commenter_id = @commenter.id
    c.save!
    c = Comment.find c.id
    c.commenter._id.should == @commenter.id
    c.commenter_id.should == @commenter._id
  end
  
end