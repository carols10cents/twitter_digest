require 'spec_helper'

describe DigestController do

  context "first time user" do
    before(:each) do
      @test_user = double("user", :last_tweet_seen => nil).as_null_object
      @test_client = double("client")
      @test_tweet = double("tweet", :id => 9000)
      controller.stub(:login_required)
      controller.stub(:current_user).and_return(@test_user)
      Twitter::Client.stub(:new).and_return(@test_client)
    end

    describe "GET 'index'" do
      it "asks twitter for the most recent 200 tweets" do
        @test_client.should_receive(:home_timeline)
                    .with(:count => 200)
                    .and_return([@test_tweet])
        get :index
      end

      it "sets the user's last_tweet_seen" do
        @test_client.stub(:home_timeline)
                    .and_return([@test_tweet])
        @test_user.should_receive(:update_attributes!).with(:last_tweet_seen => 9000)
        get :index
      end
    end
  end

  context "return user" do
    before(:each) do
      @test_user = double("user", :last_tweet_seen => 8000).as_null_object
      @test_client = double("client")
      @test_tweet = double("tweet", :id => 9000)
      controller.stub(:login_required)
      controller.stub(:current_user).and_return(@test_user)
      Twitter::Client.stub(:new).and_return(@test_client)
    end

    it "requests only tweets since last time" do
      @test_client.should_receive(:home_timeline)
                  .with(:since_id => 8000,
                        :count    => 200)
                  .and_return([@test_tweet])
      get :index
    end

    context "with tweets since last time" do
    end

    context "with no tweets since last time" do
    end
  end
end
