TwitterDigest::Application.routes.draw do
  resources :users

  root :to                         => "digest#index"

  match "/auth/:provider/callback" => "sessions#create"
  match "/login"                   => "sessions#login",
                               :as => :login
  match "/signout"                 => "sessions#destroy",
                               :as => :signout
end
