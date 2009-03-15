Before do
  Page.delete_all
end

Given /^a page "([^"]+)" with the body "([^"]+)"$/ do |title, body|
  Page.create! :title => title, :body => body
end

Given /^"([^"]+)" has been updated with "([^"]+)"$/ do |title, body|
  Page.find_by_title!(title).update_attributes! :body => body
end

Given /^a page "([^"]+)"$/ do |title|
  Page.create! :title => title, :body => 'body'
end
