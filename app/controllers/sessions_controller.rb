class SessionsController < ApplicationController
  def google_oauth2
    auth = request.env['omniauth.auth']
    user = User.find_by(google_uid: auth.uid)
    if user
      sign_in user
      redirect_to root_path and return
    else
      domain = auth.info.email.to_s.slice(/@(.+)/, 1)
      if domain.in? Rails.application.credentials.google_oauth[:domains].to_a
        user = User.create!(google_uid: auth.uid, name: auth.info.name.to_s)
        sign_in user
        redirect_to root_path and return
      end
    end

    render plain: 'ログインできませんでした', status: :forbidden
  end

end
