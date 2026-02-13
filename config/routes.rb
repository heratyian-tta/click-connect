Rails.application.routes.draw do
  get "/dashboard", to: "dashboard#index"
  get "pages/home"
  resources :user_projects
  resources :projects
  resources :skills
  devise_for :users

  root to: "pages#home"

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
  # get("/your_first_screen", { :controller => "pages", :action => "first" })
end
