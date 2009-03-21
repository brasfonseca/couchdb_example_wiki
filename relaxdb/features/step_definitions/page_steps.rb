Before do
  [Page, PageVersion].each do |klass|
    klass.all.each do |page|
      page.destroy!
    end
  end
end

Given /^a page "([^"]+)" with the body "([^"]+)"$/ do |title, body|
  Page.new(:title => title, :body => body).save!
end

Given /^"([^"]+)" has been updated with "([^"]+)"$/ do |title, body|
  page = Page.by_title(title)
  page.set_attributes :body => body
  page.save!
end

Given /^a page "([^"]+)"$/ do |title|
  Page.new(:title => title, :body => 'body').save!
end
