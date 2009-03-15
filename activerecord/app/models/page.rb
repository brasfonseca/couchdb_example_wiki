class Page < ActiveRecord::Base
  validates_presence_of :title, :body
  validates_uniqueness_of :title
  acts_as_versioned :if => lambda{|p| p.body_changed?}
  self.non_versioned_columns << 'title'
  
  def self.word_counts
    all.map(&:body).join(" ").split(/\s+/).grep(/\w+/i).inject(Hash.new(0)) do |res, word|
      res[word] += 1
      res
    end
  end
  
  def to_param
    title
  end
end