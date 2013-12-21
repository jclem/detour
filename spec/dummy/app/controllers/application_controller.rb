class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
    @user = User.first
  end
end
