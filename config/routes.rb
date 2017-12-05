# frozen_string_literal: true

Rails.application.routes.draw do
  resources :homes
  resources :bookings do
    resources :contracts, shallow: true
  end
  resources :customers
  get 'pages/home'
  get 'pages/about'

  root to: 'pages#home'
  devise_for :users
  resources :users
end
