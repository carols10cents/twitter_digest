class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user

  private
  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      session[:user_id] = nil
      @current_user = nil
      access_denied
    end
  end

  def authorized?
    !!current_user
  end

  def login_required
    authorized? || access_denied
  end

  def access_denied
    store_location
    redirect_to login_path
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def client
    Twitter.configure do |config|
      config.consumer_key = ENV['TWOAUTH_KEY']
      config.consumer_secret = ENV['TWOAUTH_SECRET']
      config.oauth_token = current_user.token
      config.oauth_token_secret = current_user.secret
    end
    @client ||= Twitter::Client.new
  end
end