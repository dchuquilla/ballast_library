Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  devise_for :users, controllers: {
                       sessions: "users/sessions",
                     }
  namespace :v1 do
    namespace :librarian do
      resources :books
    end

    namespace :member do
      resources :books, only: [:index, :show]
    end
  end
end
