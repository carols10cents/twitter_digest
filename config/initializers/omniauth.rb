Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWOAUTH_KEY'], ENV['TWOAUTH_SECRET']
end