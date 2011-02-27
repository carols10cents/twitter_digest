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
        TwitterDigest::TwitterAPI.should_receive(:request_home_timeline)
                                 .with(:client          => @test_client,
                                       :last_tweet_seen => nil)
                                 .and_return([@test_tweet])

        TwitterDigest::DigestionLogic.stub(:digest).and_return([@test_tweet])
        get :index
      end

      it "sets the user's last_tweet_seen" do
        TwitterDigest::TwitterAPI.stub(:request_home_timeline)
                                 .and_return([@test_tweet])
        TwitterDigest::DigestionLogic.stub(:digest).and_return([@test_tweet])
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
      TwitterDigest::TwitterAPI.should_receive(:request_home_timeline)
                               .with(:client          => @test_client,
                                     :last_tweet_seen => 8000)
                               .and_return([@test_tweet])
      TwitterDigest::DigestionLogic.stub(:digest).and_return([@test_tweet])
      get :index
    end

    context "with tweets since last time" do
      it "should update last_tweet_seen" do
        TwitterDigest::TwitterAPI.stub(:request_home_timeline)
                                 .and_return([@test_tweet])
        TwitterDigest::DigestionLogic.stub(:digest).and_return([@test_tweet])
        @test_user.should_receive(:update_attributes!)
                  .with(:last_tweet_seen => 9000)
        get :index
      end

      it "should have a count for @num_unabridged_tweets" do
        TwitterDigest::TwitterAPI.stub(:request_home_timeline)
                                 .and_return([@test_tweet])
        TwitterDigest::DigestionLogic.stub(:digest).and_return([@test_tweet])
        get :index
        assigns[:num_unabridged_tweets].should eql(1)
      end
    end

    context "with no tweets since last time" do
      it "should not update last_tweet_seen" do
        TwitterDigest::TwitterAPI.stub(:request_home_timeline).and_return([])
        TwitterDigest::DigestionLogic.stub(:digest).and_return([])
        @test_user.should_not_receive(:update_attributes!)
        get :index
      end

      it "should have a 0 count for @num_unabridged_tweets" do
        TwitterDigest::TwitterAPI.stub(:request_home_timeline).and_return([])
        TwitterDigest::DigestionLogic.stub(:digest).and_return([])
        get :index
        assigns[:num_unabridged_tweets].should eql(0)
      end
    end
  end
end
