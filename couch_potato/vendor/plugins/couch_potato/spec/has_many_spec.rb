require File.dirname(__FILE__) + '/spec_helper'

describe 'has_many stored inline' do
  before(:all) do
    CouchPotato::Persistence.Db!
  end
    
  before(:each) do
    @user = User.new
  end
  
  it "should build child objects" do
    @user.comments.build(:title => 'my title')
    @user.comments.first.class.should == Comment
    @user.comments.first.title.should == 'my title'
  end
  
  it "should add child objects" do
    @user.comments << Comment.new(:title => 'my title')
    @user.comments.first.class.should == Comment
    @user.comments.first.title.should == 'my title'
  end
  
  it "should persist child objects" do
    @user.comments.build(:title => 'my title')
    @user.save!
    @user = User.find @user._id
    @user.comments.first.class.should == Comment
    @user.comments.first.title.should == 'my title'
  end
end

describe 'has_many stored separately' do
  before(:all) do
    CouchPotato::Persistence.Db!
  end
  
  before(:each) do
    @commenter = Commenter.new
  end
  
  it "should build child objects" do
    @commenter.comments.build(:title => 'my title')
    @commenter.comments.first.class.should == Comment
    @commenter.comments.first.title.should == 'my title'
  end
  
  it "should create child objects" do
    @commenter.save!
    @commenter.comments.create(:title => 'my title')
    @commenter = Commenter.find @commenter._id
    @commenter.comments.first.class.should == Comment
    @commenter.comments.first.title.should == 'my title'
  end
  
  it "should create! child objects" do
    @commenter.save!
    @commenter.comments.create!(:title => 'my title')
    @commenter = Commenter.find @commenter._id
    @commenter.comments.first.class.should == Comment
    @commenter.comments.first.title.should == 'my title'
  end
  
  it "should add child objects" do
    @commenter.comments << Comment.new(:title => 'my title')
    @commenter.comments.first.class.should == Comment
    @commenter.comments.first.title.should == 'my title'
  end
  
  describe "all" do
    it "should find all dependent objects by search conditions" do
      commenter = Commenter.create!
      comment1 = commenter.comments.create! :title => 'my title'
      comment2 = commenter.comments.create! :title => 'my title'
      commenter.comments.create! :title => 'my title2'
      comments = commenter.comments.all(:title => 'my title')
      comments.size.should == 2
      comments.should include(comment1)
      comments.should include(comment2)
    end
    
    it "should return all dependent objects" do
      @commenter = Commenter.create!
      comment1 = @commenter.comments.create! :title => 'my title'
      comment2 = @commenter.comments.create! :title => 'my title2'
      comments = @commenter.comments.all
      comments.size.should == 2
      comments.should include(comment1)
      comments.should include(comment2)
    end    
  end
  
  describe "count" do
    it "should count the dependent objects by search criteria" do
      commenter = Commenter.create!
      commenter.comments.create! :title => 'my title'
      commenter.comments.create! :title => 'my title'
      commenter.comments.create! :title => 'my title2'
      commenter.comments.count(:title => 'my title').should == 2
    end
    
    it "should count all dependent objects" do
      commenter = Commenter.create!
      commenter.comments.create! :title => 'my title'
      commenter.comments.create! :title => 'my title'
      commenter.comments.create! :title => 'my title2'
      commenter.comments.count.should == 3
    end
  end
  
  describe "first" do
    it "should find the first dependent object by search conditions" do
      commenter = Commenter.create!
      comment1 = commenter.comments.create! :title => 'my title'
      comment2 = commenter.comments.create! :title => 'my title2'
      commenter.comments.first(:title => 'my title2').should == comment2
    end
    
    it "should return the first dependent object" do
      comment1 = @commenter.comments.build :title => 'my title'
      comment2 = @commenter.comments.build :title => 'my title2'
      @commenter.comments.first.should == comment1
    end    
  end
  
  describe "create" do
    it "should persist child objects" do
      @commenter.comments.build(:title => 'my title')
      @commenter.save!
      @commenter = Commenter.find @commenter._id
      @commenter.comments.first.class.should == Comment
      @commenter.comments.first.title.should == 'my title'
    end

    it "should set the _id in child objects" do
      @commenter.comments.build(:title => 'my title')
      @commenter.save!
      @commenter.comments.first._id.should_not be_nil
    end

    it "should set the _rev in child objects" do
      @commenter.comments.build(:title => 'my title')
      @commenter.save!
      @commenter.comments.first._rev.should_not be_nil
    end

    it "should set updated_at in child objects" do
      @commenter.comments.build(:title => 'my title')
      @commenter.save!
      @commenter.comments.first.updated_at.should_not be_nil
    end

    it "should set created_at in child objects" do
      @commenter.comments.build(:title => 'my title')
      @commenter.save!
      @commenter.comments.first.created_at.should_not be_nil
    end
  end
  
  describe "update" do
    it "should persist child objects" do
      comment = @commenter.comments.build(:title => 'my title')
      @commenter.save!
      comment.title = 'new title'
      @commenter.save!
      @commenter = Commenter.find @commenter._id
      @commenter.comments.first.title.should == 'new title'
    end
    
    it "should set the _rev in child objects" do
      comment = @commenter.comments.build(:title => 'my title')
      @commenter.save!
      old_rev = comment._rev
      comment.title = 'new title'
      @commenter.save!
      @commenter.comments.first._rev.should_not == old_rev
    end

    it "should set updated_at in child objects" do
      comment = @commenter.comments.build(:title => 'my title')
      @commenter.save!
      old_updated_at = comment.updated_at
      comment.title = 'new title'
      @commenter.save!
      @commenter.comments.first.updated_at.should > old_updated_at
    end
  end
  
  describe "destroy" do
    
    class AdminComment
      include CouchPotato::Persistence
      belongs_to :admin
    end
    
    class AdminFriend
      include CouchPotato::Persistence
      belongs_to :admin
    end
    
    class Admin
      include CouchPotato::Persistence
      has_many :admin_comments, :stored => :separately, :dependent => :destroy
      has_many :admin_friends, :stored => :separately
    end
    
    it "should destroy all dependent objects" do
      admin = Admin.create!
      comment = admin.admin_comments.create!
      id = comment._id
      admin.destroy
      lambda {
        CouchPotato::Persistence.Db.get(id).should
      }.should raise_error(RestClient::ResourceNotFound)
    end
    
    it "should unset _id in dependent objects" do
      admin = Admin.create!
      comment = admin.admin_comments.create!
      id = comment._id
      admin.destroy
      comment._id.should be_nil
    end
    
    it "should unset _rev in dependent objects" do
      admin = Admin.create!
      comment = admin.admin_comments.create!
      id = comment._id
      admin.destroy
      comment._rev.should be_nil
    end

    it "should nullify independent objects" do
      admin = Admin.create!
      friend = admin.admin_friends.create!
      id = friend._id
      admin.destroy
      AdminFriend.get(id).admin.should be_nil
    end
  end
end