ActionController::Routing::Routes.draw do |map|
  map.resources :pages do |pages|
    pages.resources :versions
  end
  
  map.resources :statistics
  map.root :controller => "pages", :action => 'show'
end
