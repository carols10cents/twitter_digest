require 'spec_helper'

describe DigestController do
  before(:each) do
    @test_client = double("client")
    @test_tweet  = double("tweet", :id => 9000).as_null_object
    controller.stub(:login_required)
    Twitter::Client.stub(:new).and_return(@test_client)
    Tweet.stub(:new).and_return(@test_tweet)
  end

  context "first time user" do
    before(:each) do
      @test_user = double("user", :last_tweet_seen => nil).as_null_object
      controller.stub(:current_user).and_return(@test_user)
    end

    describe "GET 'index'" do
      it "asks twitter for the most recent 800 tweets" do
        @test_client.should_receive(:home_timeline)
                    .with(:count            => 200,
                          :include_entities => true)
                    .and_return([@test_tweet])

        @test_client.should_receive(:home_timeline)
                    .with(:page             => 2,
                          :count            => 200,
                          :include_entities => true)
                    .and_return([@test_tweet])

        @test_client.should_receive(:home_timeline)
                    .with(:page             => 3,
                          :count            => 200,
                          :include_entities => true)
                    .and_return([@test_tweet])

        @test_client.should_receive(:home_timeline)
                    .with(:page             => 4,
                          :count            => 200,
                          :include_entities => true)
                    .and_return([@test_tweet])

        Tweet.stub(:digest).and_return([@test_tweet])
        get :index
      end

      it "sets the user's last_tweet_seen" do
        @test_client.stub(:home_timeline)
                    .and_return([@test_tweet])
        Tweet.stub(:digest).and_return([@test_tweet])
        @test_user.should_receive(:update_attributes!)
                  .with(:last_tweet_seen => 9000)
        get :index
      end
    end
  end

  context "return user" do
    before(:each) do
      @test_user = double("user", :last_tweet_seen => 8000).as_null_object
      controller.stub(:current_user).and_return(@test_user)
    end

    it "requests only tweets since last time" do
      @test_client.should_receive(:home_timeline)
                  .with(:since_id         => 8000,
                        :count            => 200,
                        :include_entities => true)
                  .and_return([@test_tweet])

      @test_client.should_receive(:home_timeline)
                  .with(:page             => 2,
                        :since_id         => 8000,
                        :count            => 200,
                        :include_entities => true)
                  .and_return([@test_tweet])
      @test_client.should_receive(:home_timeline)
                  .with(:page             => 3,
                        :since_id         => 8000,
                        :count            => 200,
                        :include_entities => true)
                  .and_return([@test_tweet])
      @test_client.should_receive(:home_timeline)
                  .with(:page             => 4,
                        :since_id         => 8000,
                        :count            => 200,
                        :include_entities => true)
                  .and_return([@test_tweet])
      Tweet.stub(:digest).and_return([@test_tweet])
      get :index
    end

    context "with tweets since last time" do
      it "should update last_tweet_seen" do
        @test_client.stub(:home_timeline).and_return([@test_tweet])
        Tweet.stub(:digest).and_return([@test_tweet])
        @test_user.should_receive(:update_attributes!)
                  .with(:last_tweet_seen => 9000)
        get :index
      end

      it "should have a count for @num_unabridged_tweets" do
        @test_client.stub(:home_timeline).and_return([@test_tweet])
        Tweet.stub(:digest).and_return([@test_tweet])
        get :index
        assigns[:num_unabridged_tweets].should eql(4)
      end
    end

    context "with no tweets since last time" do
      it "should not update last_tweet_seen" do
        @test_client.stub(:home_timeline).and_return([])
        Tweet.stub(:digest).and_return([])
        @test_user.should_not_receive(:update_attributes!)
        get :index
      end

      it "should have a 0 count for @num_unabridged_tweets" do
        @test_client.stub(:home_timeline).and_return([])
        Tweet.stub(:digest).and_return([])
        get :index
        assigns[:num_unabridged_tweets].should eql(0)
      end
    end
  end
end
