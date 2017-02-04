Rails.application.routes.draw do


  devise_for :users
  resources :articles

  root to: 'pages#home'
  
  get 'pages/contact'
  get 'pages/about'

end
