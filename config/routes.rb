Rails.application.routes.draw do
  root 'crawler_jobs#index'

  resources :crawler_jobs, only: %i(index show new create destroy) do
    post :confirm, on: :collection
    get :export, on: :member
    post :restart, on: :member
    delete :cancel, on: :member
  end

  get 'auth/google_oauth2/callback' => 'sessions#google_oauth2'
end
