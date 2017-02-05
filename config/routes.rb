Rails.application.routes.draw do

  devise_for :users, :controllers => { registrations: 'registrations' }
  resources :articles

  root to: 'pages#home'
  
  get 'pages/contact'
  get 'pages/about'

end
