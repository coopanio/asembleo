# frozen_string_literal: true

Rails.application.routes.draw do
  resources :consultations, shallow: true
  resources :events, shallow: true
  resources :questions, shallow: true
  resources :sessions, shallow: true
  resources :votes, shallow: true

  patch 'questions/:id/open', to: 'questions#open'
  patch 'questions/:id/close', to: 'questions#close'
  get '/', to: 'main#index'
end
