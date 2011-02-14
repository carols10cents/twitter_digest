module DigestHelper
  def digest_tweets(tweets)
    digested = []
    tweets.each do |tweet|
      conversation = []
      reply_to = tweet.in_reply_to_status_id_str
      if reply_to
        conversation << tweets.select{|x| x.id.to_s.eql?(reply_to)} 
        if !conversation.empty?
          digested << ([tweet, conversation].flatten)
        end
      else
        digested << tweet
      end
    end
    digested
  end
end
