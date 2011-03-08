class User < ActiveRecord::Base
  has_settings
  after_save :initialize_settings
  validate :timeline_order_inclusion_of, :on => :update
  validate :conversation_order_inclusion_of, :on => :update
  
  ORDER_SETTING_VALUES = [:newest_first, :oldest_first]
  
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
  
  def timeline_order_inclusion_of
    errors.add(:settings, "=> timeline order must be :newest_first or :oldest_first") unless
      ORDER_SETTING_VALUES.include?(settings.timeline_order)
  end

  def conversation_order_inclusion_of
    errors.add(:settings, "=> conversation order must be :newest_first or :oldest_first") unless
      ORDER_SETTING_VALUES.include?(settings.conversation_order)
  end
end
