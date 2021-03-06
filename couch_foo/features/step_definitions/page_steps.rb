Before do
  Page.database.database.recreate!
end

Given /^a page "([^"]+)" with the body "([^"]+)"$/ do |title, body|
  Page.new(:title => title, :body => body).save!
end

Given /^"([^"]+)" has been updated with "([^"]+)"$/ do |title, body|
  Page.find_by_title(title).update_attributes :body => body
end

Given /^a page "([^"]+)"$/ do |title|
  Page.new(:title => title, :body => 'body').save!
end
