module TwitterDigest
  module DigestionLogic
    extend self

    def digest(tweets)
      digested = DigestedStream.new

      group_direct_conversations(digested, tweets)
      group_replies_to_users_with_conversations(digested, tweets)
      group_retweet_replies(digested, tweets)
      group_link_discussions(digested, tweets)

      digested
    end

    private
    def group_direct_conversations(digested, tweets)
      tweets.each do |tweet|
        # This tweet may have been pulled into a conversation already.
        # If it has, don't try to add it to a conversation again.
        if !digested.include?(tweet)
          if tweet.in_reply_to_status_id
            success = attempt_to_digest_into_conversation(
                        tweet,
                        tweets,
                        digested
                      )
            if !success
              digested << tweet
            end
          else
            digested << tweet
          end
        end
      end
    end

    def attempt_to_digest_into_conversation(tweet, tweets, digested)
      reply_to = tweet.in_reply_to_status_id
      existing_reply = tweets.find{|t| t.id == reply_to}

      if existing_reply
        existing_conversation = digested.find_conversation_by_tweet(
                                  existing_reply
                                )
        if existing_conversation
          existing_conversation.add_tweet(tweet)
          return true
        else
          if existing_reply.in_reply_to_status_id
            success = attempt_to_digest_into_conversation(
                        existing_reply,
                        tweets,
                        digested
                      )
            if !success
              digested << Conversation.new(existing_reply, tweet)
            else
              attempt_to_digest_into_conversation(
                tweet,
                tweets,
                digested
              )
            end
          else
            digested << Conversation.new(existing_reply, tweet)
          end
          return true
        end
      end
      return false
    end

    def group_replies_to_users_with_conversations(digested, tweets)
      # If tweets are already in conversations, don't consider here.
      reply_to_user_tweets = digested.stream.select do |t|
                               t.respond_to?(:in_reply_to_screen_name) &&
                                 t.in_reply_to_screen_name &&
                                   !t.in_reply_to_status_id
                             end
      reply_to_user_tweets.each do |tweet|
        user_name = tweet.user.screen_name
        reply_user_name = tweet.in_reply_to_screen_name
        conversations = digested.stream.select{|c|
                          c.respond_to?(:participants) &&
                            c.participants.include?(user_name) &&
                              c.participants.include?(reply_user_name)
                        }
        if !conversations.empty?
          digested.delete(tweet)
          consolidated = Conversation.new(tweet)
          conversations.each do |conversation|
            digested.delete(conversation)
            conversation.tweets.each do |con_tweet|
              consolidated.add_tweet(con_tweet)
            end
          end
          digested << consolidated
        end
      end
    end

    def group_retweet_replies(digested, tweets)
      # If tweets are already in conversations, we are not considering
      # them as candidates for collapsing, but we will look in existing
      # conversations for the tweet being replied to.
      tweets_containing_rt = digested.stream.select do |t|
                               t.respond_to?(:text) && t.text &&
                                 t.text.match(/ rt /i)
                             end
      tweets_containing_rt.each do |tweet|
        retweeted_match = tweet.text.match(/ rt @[^:]*: (.*)$/i)
        if retweeted_match
          retweeted_text = retweeted_match[1]
          existing_retweeted = tweets.find do |t|
                                 t.text &&
                                   t.text.start_with?(retweeted_text)
                               end
          if existing_retweeted
            existing_conversation =
              digested.find_conversation_by_tweet(existing_retweeted)
            if existing_conversation
              digested.delete(tweet)
              existing_conversation.add_tweet(tweet)
            else
              digested.delete(tweet)
              digested.delete(existing_retweeted)
              digested << Conversation.new(tweet, existing_retweeted)
            end
          end
        end
      end
    end

    def group_link_discussions(digested, tweets)
      # If tweets are already in conversations, don't consider here.

      tweets_by_urls_mentioned = digested.stream.group_by do |tweet|
        if tweet.respond_to?(:entities) &&
             tweet.entities &&
               !tweet.entities.urls.empty?
          # TODO: If a tweet mentions multiple URLs,
          # only the first will be considered...
          tweet.entities.urls.first.expanded_url
        end
      end

      multiple_tweets_one_url = tweets_by_urls_mentioned.select do |k, v|
                                  k && v.size > 1
                                end
      multiple_tweets_one_url.each do |key, value|
        consolidated = Conversation.new
        value.each do |tweet|
          digested.delete(tweet)
          consolidated.add_tweet(tweet)
        end
        consolidated.topics = [key]
        consolidated.type = "link"
        digested << consolidated
      end
    end
  end
end