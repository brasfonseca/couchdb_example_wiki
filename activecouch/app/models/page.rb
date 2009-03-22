class Page < ActiveCouch::Base
  
  include Validatable
  
  site YAML::load(File.open(File.join(Rails.root,
                    'config', 'activecouch.yml')))[Rails.env]['site']
  
  has :title
  has :body
  has :created_at
  
  before_save do |page|
    page.created_at = Time.now.strftime("%Y/%m/%d %H:%M:%S %z") if page.created_at.blank?
  end
  
  after_save :create_version
  
  validates_presence_of :title
  validates_presence_of :body
  
  def new_record?
    new?
  end
  
  def versions
    PageVersion.find :all, :params => {:page_id => self.id}
  end
  
  
  def initialize_with_body_dirty_tracking(*args)
    initialize_without_body_dirty_tracking(*args)
    instance_eval <<-EVAL
      def body=(value)
        @body_was = attributes[:body]
        attributes[:body] = value
      end
    EVAL
  end
  alias_method_chain :initialize, :body_dirty_tracking
  
  # def self.word_counts
  #     WordCount.by_count(:reduce => true, :group => true)['rows'].map{|row| [row['key'], row['value']]}
  #   end
  
  # def body_with_keep_old=(new_body)
  #     @body_was ||= body
  #     self.body_without_keep_old = new_body
  #   end
  #   alias_method_chain :body=, :keep_old
    
  private
  
  def versions_count
    PageVersion.count :params => {:page_id => self.id}
  end
  
  def create_version
    PageVersion.new(:page_id => id, :body => @body_was, :version => versions_count + 1).save unless @body_was.blank?
  end
  
end