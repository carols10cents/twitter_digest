class DigestController < ApplicationController
  before_filter :login_required

  def index
    @last_tweet_seen = params[:since_id] || current_user.last_tweet_seen
    if @last_tweet_seen
      @tweets = client.home_timeline(:since_id => @last_tweet_seen,
                                     :count    => 200)
    else
      @tweets = client.home_timeline(:count => 200)
      #flash notice that since this is 1st time, last 200 are shown, next time will be since this time
    end
    if !@tweets.empty?
      current_user.update_attributes!(:last_tweet_seen => @tweets[0].id)
    end
  end

end
