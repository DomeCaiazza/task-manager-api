Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  devise_for :users

  root to: redirect("/api-docs")

  namespace :api do
    namespace :v1 do
      resources :tasks
    end
  end
end
