# frozen_string_literal: true

Rails.application.routes.draw do
  resources :consultations, only: %i[new create edit update show destroy]
  resources :events, only: %i[new create edit update destroy]
  resources :questions, only: %i[new create edit update show destroy]
  resources :sessions, only: %i[new create]
  resources :votes, only: %i[create]

  get '/', to: 'main#index'
end
