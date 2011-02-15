module DigestHelper
  def digest_tweets(tweets)
    @digested = []
    tweets.each do |tweet|

      if !tweet.pulled_into_conversation
        if tweet.in_reply_to_status_id
          success = attempt_to_digest(tweet, tweets)
          if !success
            @digested << tweet
          end
        else
          @digested << tweet
        end
      end

    end
    @digested
  end

  def attempt_to_digest(tweet, tweets)
    reply_to = tweet.in_reply_to_status_id
    existing_conversation = @digested.find{|c| c[:ids] && c[:ids].include?(reply_to) }
    if existing_conversation
      add_to_conversation(tweet, existing_conversation)
      return true
    else
      existing_reply = tweets.find{|t| t.id == reply_to}
      if existing_reply
        if existing_reply.in_reply_to_status_id
          success = attempt_to_digest(existing_reply, tweets)
          if !success
            start_new_conversation(existing_reply, tweet)
          else
            attempt_to_digest(tweet, tweets)
          end
        else
          start_new_conversation(existing_reply, tweet)
        end
        return true
      else
        return false
      end
    end
  end

  def add_to_conversation(tweet, conversation)
    conversation[:conversation] << tweet
    conversation[:conversation].sort!{|a, b| b.created_at <=> a.created_at}
    conversation[:ids] = conversation[:conversation].collect{|c| c.id}
    tweet.pulled_into_conversation = true
  end

  def start_new_conversation(tweet1, tweet2)
    @digested << {:conversation => [], :ids => []}
    add_to_conversation(tweet1, @digested.last)
    add_to_conversation(tweet2, @digested.last)
  end
end
