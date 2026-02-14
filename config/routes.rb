Rails.application.routes.draw do
  resources :user_skills
  root to: "pages#home"
  get "pages/home"
  get "/dashboard", to: "dashboard#index"

  resources :user_projects
  resources :projects
  resources :skills
  devise_for :users


get("/", { :controller => "pages", :action => "home" })
get("/index", { :controller => "pages", :action => "index" })
get("/dashboard", { :controller => "dashboard", :action => "index" })
  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
  # get("/your_first_screen", { :controller => "pages", :action => "first" })
end
