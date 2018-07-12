Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users

  root 'crawler_jobs#index'

  resources :crawler_jobs, only: %i(index new create destroy) do
    get :export, on: :member
  end
end
