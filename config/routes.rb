Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users

  resources :crawler_jobs, only: %i(index new create)
end
