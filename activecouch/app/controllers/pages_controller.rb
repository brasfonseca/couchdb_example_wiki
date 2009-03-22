class PagesController < ApplicationController
  
  def index
    @pages = Page.find_from_url('/pages/_design/by_created_at/_view/by_created_at')
  end
  
  def new
    @page = Page.new :title => params[:title]
  end
  
  def create
    @page = Page.new params[:page]
    if @page.save
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
    params[:page].each do |key, value|
      @page.send("#{key}=", value)
    end
    if @page.save
      redirect_to page_path(@page.title)
    else
      render :edit
    end
  end
  
  def show
    @page = Page.find_from_url('/pages/_design/by_created_at/_view/by_created_at').first unless params[:id]
    @page ||= load_page
    redirect_to new_page_path(:title => params[:id]) unless @page
  end
  
  
end