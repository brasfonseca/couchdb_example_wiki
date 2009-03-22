Before do
  COUCH_DB.delete '/'
  COUCH_DB.put '/'
end

Given /^a page "([^"]+)" with the body "([^"]+)"$/ do |title, body|
  Page.new(:title => title, :body => body).save!
end

Given /^"([^"]+)" has been updated with "([^"]+)"$/ do |title, body|
  Page.by_title(:key => title, :limit => 1).first.update_attributes :body => body
end

Given /^a page "([^"]+)"$/ do |title|
  Page.new(:title => title, :body => 'body').save!
end
