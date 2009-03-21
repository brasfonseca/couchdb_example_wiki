# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def linkify(text)
    text.gsub(/([A-Z][a-z]+([A-Z][a-z]+)+)/) do
      link_to($1, page_path($1))
    end
  end
end
