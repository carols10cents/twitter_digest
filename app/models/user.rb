class User < ActiveRecord::Base
  has_settings
  after_save :initialize_settings
  
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid      = auth["uid"]
      user.name     = auth["user_info"]["name"]
      user.nickname = auth["user_info"]["nickname"]
      user.token    = auth["credentials"]["token"]
      user.secret   = auth["credentials"]["secret"]
    end
  end
  
  def initialize_settings
    settings.timeline_order     = :newest_first
    settings.conversation_order = :oldest_first
  end
end
