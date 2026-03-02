class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @projects = Project.all
    @recent_users = User.order(created_at: :desc).limit(3)
    @recent_projects = Project.order(created_at: :desc).limit(3)
    @skills = current_user.skills
  end
end
