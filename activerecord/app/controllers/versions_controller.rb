class VersionsController < ApplicationController
  def index
    @page = Page.find_by_title! params[:page_id]
    @versions = @page.versions
  end
  
  def show
    @page = Page.find_by_title! params[:page_id]
    @version = @page.versions.find_by_version! params[:id]
  end
end