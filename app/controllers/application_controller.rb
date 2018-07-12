class ApplicationController < ActionController::Base
  # before_action :authenticate_user!
  before_action do
    authenticate_or_request_with_http_basic do |user, pass|
      user == Rails.application.credentials.basic_auth_user && pass == Rails.application.credentials.basic_auth_password
    end
  end
end
