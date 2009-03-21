# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def linkify(text)
    text.gsub(/([A-Z][a-z]+([A-Z][a-z]+)+)/) do
      link_to($1, page_path($1))
    end
  end
  
  def errors_for(object)
    return unless object.errors.any?
    object.errors.to_a.inject("<h2 class=\"error\">Errors saving the #{object.class.name.humanize}</h2><ul class=\"error\">") do |res, error|
      field, message = error
      res + "<li>#{field.to_s.humanize}: #{message}</li>"
    end + "</ul>"
  end
end
