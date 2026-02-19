class ProfilesController < ApplicationController
  before_action :set_profile, only: %i[ show ]

  # GET /profiles
  def index
    @users = User.all
  end

  # GET /profiles/1
  def show
  end

  private

  def set_profile
    @user = User.find(params.expect(:id))
  end
end
