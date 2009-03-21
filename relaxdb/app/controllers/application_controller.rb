# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  private
  
  def load_page(title = nil)
    Page.by_title(title || params[:id])
  end
  
  def load_page!(title = nil)
    load_page(title) || not_found
  end
  
  def not_found
    raise :not_found
  end
end
