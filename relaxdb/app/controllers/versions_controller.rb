class VersionsController < ApplicationController

  def index
    @page = load_page! params[:page_id]
    @versions = @page.page_versions
  end
  
  def show
    @page = load_page! params[:page_id]
    @version = PageVersion.by__id(:key => params[:id]).first
  end
end