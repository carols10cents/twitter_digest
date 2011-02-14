module DigestHelper
  def digest_tweets(tweets)
    digested = []
    pulled_into_conversation = []
    tweets.each do |tweet|
      reply_to = tweet.in_reply_to_status_id_str

      if reply_to
        existing_conversation = digested.find{|c| c[:ids] && c[:ids].include?(reply_to)}
        if existing_conversation
          existing_conversation[:conversation] << tweet
          existing_conversation[:conversation].sort!{|a, b| b.created_at <=> a.created_at}
          existing_conversation[:ids] = existing_conversation[:conversation].collect{|c| c.id}

        else
          orig = tweets.find{|t| t.id == reply_to}
          if orig
            digested << {:conversation => [tweet, orig],
                         :ids          => [tweet.id, orig.id]
                        }
            pulled_into_conversation << orig.id
          end
        end
      elsif !pulled_into_conversation.include?(tweet.id)
        digested << tweet
      end
    end
    digested
  end
end
