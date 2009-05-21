class VersionsController < ApplicationController

  def index
    @page = load_page! params[:page_id]
    @versions = db.view PageVersion.by_page_id(:key => @page.id)
  end
  
  def show
    @page = load_page! params[:page_id]
    @version = db.view(PageVersion.by_page_id_and_version(:key => [@page.id, params[:id].to_i])).first
  end
end