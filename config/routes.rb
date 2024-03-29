# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :tasks, except: %i[new edit], param: :slug
  resources :users, only: %i[create index]
  resource :sessions, only: %i[create destroy]
  resources :comments, only: :create
  resources :preferences, only: %i[show update]
  root "home#index"
  get "*path", to: "home#index", via: :all
end

