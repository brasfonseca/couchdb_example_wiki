Given /^a page "([^"]+)" with the body "([^"]+)"$/ do |title, body|
  DB.save! Page.new(:title => title, :body => body)
end

Given /^"([^"]+)" has been updated with "([^"]+)"$/ do |title, body|
  page = DB.view(Page.by_title(:key => title)).first
  page.attributes = {:body => body}
  DB.save! page
end

Given /^a page "([^"]+)"$/ do |title|
  DB.save! Page.new(:title => title, :body => 'body')
end
