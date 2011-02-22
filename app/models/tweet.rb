class Tweet
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :id, :user, :created_at, :text, :entities,
                :in_reply_to_status_id, :in_reply_to_screen_name

  def initialize(attributes = {})
    attributes.each do |name, value|
      if name.eql?("in_reply_to_screen_name") && value
        value = "@" + value
      end
      if name.eql?("user")
        value.screen_name = "@" + value.screen_name
      end
      send("#{name}=", value) if respond_to?("#{name}=")
    end
  end

  def persisted?
    false
  end
end