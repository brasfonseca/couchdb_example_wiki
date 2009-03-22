class VersionsController < ApplicationController

  def index
    @page = load_page! params[:page_id]
    @versions = @page.versions
  end
  
  def show
    @page = load_page! params[:page_id]
    @version = PageVersion.find :first, :params => {:id => params[:id]} 
  end
end