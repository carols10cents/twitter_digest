TwitterDigest::Application.routes.draw do
  root :to => "digest#index"

  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
end
