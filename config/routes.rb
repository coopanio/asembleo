# frozen_string_literal: true

Rails.application.routes.draw do
  get   'consultations/:consultation_id/questions/import',           to: 'questions#import'
  post  'consultations/:consultation_id/questions/import',           to: 'questions#import'

  resources :consultations do
    resources :questions do
      resources :options
    end

    resources :question_groups
  end

  resources :events
  resources :users
  resources :sessions
  resources :votes
  resources :diagnostics

  patch 'consultations/:consultation_id/questions/:id/open',         to: 'questions#open'
  patch 'consultations/:consultation_id/questions/:id/open_all',     to: 'questions#open_all'
  patch 'consultations/:consultation_id/questions/:id/close',        to: 'questions#close'
  patch 'consultations/:consultation_id/questions/:id/close_all',    to: 'questions#close_all'
  get   'consultations/:consultation_id/questions/:id/option',       to: 'questions#new_option'
  get   'consultations/:consultation_id/questions/:id/tally',        to: 'questions#tally'
  post  'events/:id/tokens',          to: 'events#create_tokens'
  get   'events/:id/tokens',          to: 'events#new_tokens'
  post  'events/:id/deactivate_tokens', to: 'events#deactivate_tokens'
  patch 'events/:id/token/:token_id', to: 'events#update_token'
  get   'events/:id/next',            to: 'events#next_question'
  post  'sessions/email',             to: 'sessions#create_from_email', as: 'magic_login'
  get   'sessions/:token/login',      to: 'sessions#create', as: 'magic_link'
  get   'confirmations/:fingerprint',        to: 'users#confirm', as: 'confirmations'
  get   'approvals/:fingerprint',            to: 'users#approve', as: 'approvals'
  get   'about',                      to: 'pages#about'
  get   '',                           to: 'main#index'

  root to: 'main#index'
end
