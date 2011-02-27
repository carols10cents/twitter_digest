require_relative "../../lib/digestion_logic.rb"

class DigestController < ApplicationController
  before_filter :login_required

  def index
    @last_tweet_seen = params[:since_id] || current_user.last_tweet_seen

    if @last_tweet_seen
      @tweets_from_api = client.home_timeline(
        :since_id         => @last_tweet_seen,
        :count            => 200,
        :include_entities => true
      )
    else
      @tweets_from_api = client.home_timeline(
        :count            => 200,
        :include_entities => true
      )
      # TODO: flash notice that since this is 1st time,
      # last 200 are shown, next time will be since this time
    end

    @unabridged_tweets = @tweets_from_api.map{|t| Tweet.new(t)}
    @digested_tweets   = TwitterDigest::DigestionLogic.digest(
                           @unabridged_tweets
                         )

    current_user.update_attributes!(
      :last_tweet_seen => @unabridged_tweets[0].id
    ) unless @unabridged_tweets.empty?

    @num_unabridged_tweets = @unabridged_tweets.size
    @num_in_conversations  = @num_unabridged_tweets - @digested_tweets.size
  end
end