module TwitterDigest
  module DigestionLogic
    extend self

    def digest(tweets)
      digested = DigestedStream.new

      group_direct_conversations(digested, tweets)
      group_replies_to_users_with_conversations(digested, tweets)

      digested
    end

    private
    def group_direct_conversations(digested, tweets)
      tweets.each do |tweet|
        # This tweet may have been pulled into a conversation already.
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
        existing_conversation = digested.find_conversation_by_tweet(existing_reply)
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
      # If tweets are already in conversations, we are not considering them here.
      reply_to_user_tweets = digested.stream.select{|t|
                               t.respond_to?(:in_reply_to_screen_name) &&
                                 t.in_reply_to_screen_name &&
                                   !t.in_reply_to_status_id
                             }
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
  end
end