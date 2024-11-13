Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  devise_for :users, controllers: {
                       sessions: "users/sessions",
                     }
  namespace :v1 do
    namespace :librarian do
      resources :books do
        collection do
          get :search
        end
        member do
          resources :book_copies, except: [:new, :edit], param: :book_copy_id
        end
      end

      resources :borrowings, only: [:index, :show, :update, :destroy] do
        member do
          patch :return
        end
        collection do
          post :borrow
        end
      end
    end

    namespace :member do
      resources :books, only: [:index, :show] do
        collection do
          get :search
        end
        member do
          resources :book_copies, only: [:index, :show], param: :book_copy_id
        end
      end

      resources :borrowings, only: [:index, :show] do
        collection do
          post :borrow
        end
      end
    end
  end
end
