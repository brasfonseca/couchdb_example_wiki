Before do
  [:pages, :page_versions].each do |db|
    Page.connection.delete "/#{db}" rescue nil
    Page.connection.put "/#{db}"
  end
  
  [ById, ByCreatedAt, ByTitle].each do |view|
    ActiveCouch::Exporter.export(Page.connection.site.to_s, view, :database => 'pages')
  end
  
  [ByPageId, ById].each do |view|
    ActiveCouch::Exporter.export(Page.connection.site.to_s, view, :database => 'page_versions')
  end
  
end

Given /^a page "([^"]+)" with the body "([^"]+)"$/ do |title, body|
  Page.new(:title => title, :body => body).save
end

Given /^"([^"]+)" has been updated with "([^"]+)"$/ do |title, body|
  page = Page.find(:first, :params => {:title => title})
  page.body = body
  page.save
end

Given /^a page "([^"]+)"$/ do |title|
  Page.new(:title => title, :body => 'body').save
end
