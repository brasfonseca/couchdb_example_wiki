class PagesController < ApplicationController
  
  def index
    @pages = db.view Page.by_created_at
  end
  
  def new
    @page = Page.new :title => params[:title]
  end
  
  def create
    @page = Page.new params[:page]
    if db.save @page
      redirect_to page_path(:id => @page.title)
    else
      render :new
    end
  end
  
  def edit
    @page = load_page!
  end
  
  def update
    @page = load_page!
    @page.attributes = params[:page]
    if db.save @page
      redirect_to page_path(@page.title)
    else
      render :edit
    end
  end
  
  def show
    @page = db.view(Page.by_created_at(:limit => 1)).first unless params[:id]
    @page ||= load_page
    redirect_to new_page_path(:title => params[:id]) unless @page
  end
  
  
end