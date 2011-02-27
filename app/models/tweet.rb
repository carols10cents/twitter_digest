class Tweet
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :id, :user, :created_at, :text, :entities,
                :in_reply_to_status_id, :in_reply_to_screen_name

  def initialize(attributes = {})
    attributes.each do |name, value|
      next unless respond_to?("#{name}=")

      case name
      when "in_reply_to_screen_name"
        value = "@" + value
      when "user"
        value.screen_name = "@" + value.screen_name
      end unless value.nil?

      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end