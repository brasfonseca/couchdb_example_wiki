class PagesController < ApplicationController
  
  def index
    @pages = Page.all
  end
  
  def new
    @page = Page.new :title => params[:title]
  end
  
  def create
    @page = Page.new params[:page]
    if @page.save
      redirect_to @page
    else
      render :new
    end
  end
  
  def edit
    @page = Page.find_by_title! params[:id]
  end
  
  def update
    @page = Page.find_by_title! params[:id]
    if @page.update_attributes params[:page]
      redirect_to page_path(@page)
    else
      render :edit
    end
  end
  
  def show
    @page = Page.first unless params[:id]
    @page ||= Page.find_by_title params[:id]
    redirect_to new_page_path(:title => params[:id]) unless @page
  end
end