# frozen_string_literal: true

Rails.application.routes.draw do
  resources :consultations do
    resources :questions do
      resources :options
    end

    resources :question_groups
  end

  resources :events
  resources :sessions
  resources :votes

  get   'sessions/:token/login',      to: 'sessions#create'
  patch 'questions/:id/open',         to: 'questions#open'
  patch 'questions/:id/open_all',     to: 'questions#open_all'
  patch 'questions/:id/close',        to: 'questions#close'
  patch 'questions/:id/close_all',    to: 'questions#close_all'
  get   'questions/:id/option',       to: 'questions#new_option'
  get   'questions/:id/tally',        to: 'questions#tally'
  post  'events/:id/tokens',          to: 'events#create_tokens'
  get   'events/:id/tokens',          to: 'events#new_tokens'
  patch 'events/:id/token/:token_id', to: 'events#update_token'
  get   'events/:id/next',            to: 'events#next_question'
  get   '/',                          to: 'main#index'

  root to: 'main#index'
end
