require_relative "../../lib/digestion_logic.rb"
require_relative "../../lib/twitter_api.rb"

class DigestController < ApplicationController
  before_filter :login_required

  def index
    @last_tweet_seen = params[:since_id] || current_user.last_tweet_seen

    @tweets_from_api = TwitterDigest::TwitterAPI.request_home_timeline(
                         :client          => client,
                         :last_tweet_seen => @last_tweet_seen
                       )
    # TODO: flash notice that if this is user's 1st time,
    # last 200 are shown, next time will be since this time

    @unabridged_tweets = @tweets_from_api.map{|t| Tweet.new(t.attrs)}
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