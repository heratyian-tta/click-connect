class ApplicationController < ActionController::Base
  skip_forgery_protection
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, :keys => [:first_name, :last_name, :bio, :skill_ids => []])
    devise_parameter_sanitizer.permit(:account_update, :keys => [:first_name, :last_name, :bio, :skill_ids => []])
  end
end
