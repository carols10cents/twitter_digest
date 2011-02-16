class Tweet
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :id, :created_at, :in_reply_to_status_id, :user, :text
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value) if respond_to?("#{name}=")
    end
  end
  
  def persisted?
    false
  end
  
  def self.digest(tweets)
    digested = DigestedStream.new
    tweets.each do |tweet|
      # This tweet may have been pulled into a conversation already.
      if !digested.include?(tweet)
        if tweet.in_reply_to_status_id
          success = self.attempt_to_digest(tweet, tweets, digested)
          if !success
            digested << tweet
          end
        else
          digested << tweet
        end
      end
    end
    digested
  end
  
  def self.attempt_to_digest(tweet, tweets, digested)
    reply_to = tweet.in_reply_to_status_id
    existing_reply = tweets.find{|t| t.id == reply_to}

    if existing_reply
      existing_conversation = digested.find_conversation_by_tweet(existing_reply)
      if existing_conversation
        existing_conversation.add_tweet(tweet)
        return true
      else
        if existing_reply.in_reply_to_status_id
          success = self.attempt_to_digest(existing_reply, tweets, digested)
          if !success
            digested << Conversation.new(existing_reply, tweet)
          else
            Tweet.attempt_to_digest(tweet, tweets, digested)
          end
        else
          digested << Conversation.new(existing_reply, tweet)
        end
        return true
      end
    end
    return false
  end
end