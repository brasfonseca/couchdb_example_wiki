class VersionsController < ApplicationController

  def index
    @page = load_page! params[:page_id]
    @versions = @page.page_versions
  end
  
  def show
    @page = load_page! params[:page_id]
    @version = PageVersion.first :version => params[:id].to_i, :page_id => @page.id
  end
end