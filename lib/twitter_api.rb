module TwitterDigest
  module TwitterAPI
    extend self

    def request_home_timeline(params = {})
      client     = params[:client]
      api_params = {:count            => 200,
                    :include_entities => true}

      unless params[:last_tweet_seen].nil?
        api_params[:since_id] = params[:last_tweet_seen]
      end

      tweets_from_api = client.home_timeline(api_params)

      (2..4).each do |i|
        api_params[:page] = i
        next_page = client.home_timeline(api_params)
        tweets_from_api.concat(next_page)
      end
      tweets_from_api
    end
  end
end