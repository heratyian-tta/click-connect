Rails.application.routes.draw do
  root to: "pages#home"
  get "/dashboard", to: "dashboard#index"

  resources :user_skills
  resources :user_projects
  resources :projects
  resources :skills
  resources :profiles
  devise_for :users

  get("/", { :controller => "pages", :action => "home" })
  get("/index", { :controller => "pages", :action => "index" })

  get("/dashboard", { :controller => "dashboard", :action => "index" })
  get("/dashboard/:user", { :controller => "dashboard", :action => "index" })

  get("/profiles", { :controller => "profiles", :action => "index" })

  get("/skills", { :controller => "skills", :action => "index" })
  get("/skills/edit", { :controller => "skills", :action => "edit" })
  
  get("/skills/:id", { :controller => "skills", :action => "show" })
  get("/skills/:id/edit", { :controller => "skills", :action => "edit" })
  post("/skills", { :controller => "skills", :action => "create" })
  patch("/skills/:id", { :controller => "skills", :action => "update" })
  delete("/skills/:id", { :controller => "skills", :action => "destroy" })

  get("/user_skills/:id", { :controller => "user_skills", :action => "show" })
  get("/skills/user_skills", { :controller => "user_skills", :action => "index" })

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
  # get("/your_first_screen", { :controller => "pages", :action => "first" })
end
