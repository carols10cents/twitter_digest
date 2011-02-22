require_relative "../../lib/digestion_logic.rb"

class DigestController < ApplicationController
  before_filter :login_required

  def index
    @last_tweet_seen = params[:since_id] || current_user.last_tweet_seen

    if @last_tweet_seen
      @tweets_hash = client.home_timeline(:since_id         => @last_tweet_seen,
                                          :count            => 200,
                                          :include_entities => true)
    else
      @tweets_hash = client.home_timeline(:count            => 200,
                                          :include_entities => true)
      #TODO: flash notice that since this is 1st time, last 200 are shown, next time will be since this time
    end

    @total_tweets = []
    @tweets_hash.each do |tweet_hash|
      @total_tweets << Tweet.new(tweet_hash)
    end
    @tweets = TwitterDigest::DigestionLogic.digest(@total_tweets)

    current_user.update_attributes!(
      :last_tweet_seen => @total_tweets[0].id
    ) unless @total_tweets.empty?

    @num_total_tweets = @total_tweets.size
    @num_in_conversations = @num_total_tweets - @tweets.size
  end

end
