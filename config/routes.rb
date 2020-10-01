# frozen_string_literal: true

Rails.application.routes.draw do
  resources :consultations, shallow: true
  resources :events,        shallow: true
  resources :questions,     shallow: true
  resources :sessions,      shallow: true
  resources :votes,         shallow: true

  patch 'questions/:id/open',  to: 'questions#open'
  patch 'questions/:id/close', to: 'questions#close'
  post  'events/:id/tokens',   to: 'events#generate_tokens'
  get   'events/:id/next',     to: 'events#next_question'
  get   '/',                   to: 'main#index'
end
