Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/', to: 'welcome#index'
  get "/merchants/:merchant_id/dashboard", to: "merchants#show"
  get '/admin', to: "admin/dashboard#index"

  resources :merchants do
    resources :items, except: [:destroy], controller: :merchant_items
    resources :bulk_discounts
    resources :invoices, only: [:index, :show, :update], controller: :merchant_invoices
  end

  namespace :admin do
    resources :invoices, only: [:index, :show, :update]
    resources :merchants
  end
end
