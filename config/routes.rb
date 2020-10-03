# frozen_string_literal: true

Rails.application.routes.draw do
  resources :consultations
  resources :events
  resources :questions do
    resources :options
  end
  resources :sessions
  resources :votes

  patch 'questions/:id/open',   to: 'questions#open'
  patch 'questions/:id/close',  to: 'questions#close'
  get   'questions/:id/option', to: 'questions#new_option'
  get   'questions/:id/tally',  to: 'questions#tally'
  post  'events/:id/tokens',    to: 'events#generate_tokens'
  get   'events/:id/next',      to: 'events#next_question'
  get   '/',                    to: 'main#index'

  root to: 'main#index'
end
