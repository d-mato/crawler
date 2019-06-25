class ApplicationController < ActionController::Base
  def authenticate_user!
    redirect_to '/auth/google_oauth2' unless current_user
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
