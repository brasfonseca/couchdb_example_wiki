require 'rubygems'
gem 'jchris-couchrest'
require 'couchrest'

Before do
  server = CouchRest.new
  @database = server.database "couchapp_wiki"
end

Given /^a page "([^"]+)" with the body "([^"]+)"$/ do |title, body|
  @database.post '/', {:title => title, :body => body}
end

Given /^"([^"]+)" has been updated with "([^"]+)"$/ do |title, body|
  page = @database.view 'pages', 'by_title', :key => title
  page['body'] = body
  @database.put page.id, page
end

Given /^a page "([^"]+)"$/ do |title|
  @database.post '/', {:title => title, :body => 'the body'}
end
