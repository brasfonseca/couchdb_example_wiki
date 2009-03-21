require File.dirname(__FILE__) + '/spec_helper'

describe "find" do
  before(:all) do
    CouchPotato::Persistence.Db!
  end
  before(:each) do
    @comment = Comment.create! :title => 'title'
  end
  
  it "should find by id" do
    Comment.find(@comment.id).should == @comment
  end
  
  it "should assign the id" do
    Comment.find(@comment.id)._id.should == @comment._id
  end
  
  it "should assign the revision" do
    Comment.find(@comment.id)._rev.should == @comment._rev
  end
  
  it "should reurn nil of nothing found" do
    Comment.find(@comment.id.succ).should be_nil
  end
end

describe 'first' do
  before(:each) do
    CouchPotato::Persistence.Db.delete!
    CouchPotato::Persistence.Db!
    @comment = Comment.create! :title => 'title'
  end
  
  it "should find the first matching object" do
    Comment.first(:title =>'title').should == @comment
  end
  
  it "should return nil if nothing found" do
    Comment.first(:title =>'title2').should be_nil
  end
end

describe 'last' do
  before(:each) do
    CouchPotato::Persistence.Db.delete!
    CouchPotato::Persistence.Db!
    @comment = Comment.create! :title => 'title'
  end
  
  it "should find the last matching object" do
    Comment.last(:title =>'title').should == @comment
  end
  
  it "should return nil if nothing found" do
    Comment.last(:title =>'title2').should be_nil
  end
end


describe 'all' do
  before(:each) do
    CouchPotato::Persistence.Db.delete!
    CouchPotato::Persistence.Db!
    @comment = Comment.create! :title => 'title'
    @comment2 = Comment.create! :title => 'title'
  end
  
  it "should find the matching objects" do
    comments = Comment.all(:title =>'title')
    comments.size.should == 2
    comments.should include(@comment)
    comments.should include(@comment2)
  end
  
  it "should return [] if nothing found" do
    Comment.all(:title =>'title2').should == []
  end
end

describe 'count' do
  before(:each) do
    CouchPotato::Persistence.Db.delete!
    CouchPotato::Persistence.Db!
    @comment = Comment.create! :title => 'title'
    @comment2 = Comment.create! :title => 'title'
  end
  
  it "should count the matching objects" do
    Comment.count(:title =>'title').should == 2
  end
  
  it "should not count non matching objects" do
    Comment.count(:title =>'title2').should == 0
  end
end