require 'spec_helper'

describe Conversation do
  before(:each) do
    @tweet5 = Tweet.new(Hashie::Mash.new({:id => 5,
                        :in_reply_to_status_id => 2,
                        :created_at => "Sun Feb 13 18:02:00 +0000 2011",
                        :text => "@testuser2 @testuser2 @testuser2 Winter makes us appreciate spring",
                        :user => Hashie::Mash.new({
                          :screen_name => "testuser1"})
                        }))
    @tweet4 = Tweet.new(Hashie::Mash.new({:id => 4,
                        :in_reply_to_status_id => 2,
                        :created_at => "Sun Feb 13 18:03:00 +0000 2011",
                        :text => "@testuser2 Yeah, so much better than last week. I can sit outside! #happiness",
                        :user => Hashie::Mash.new({
                          :screen_name => "testuser3"})
                        }))
    @tweet3 = Tweet.new(Hashie::Mash.new({:id => 3,
                        :in_reply_to_status_id => 2,
                        :created_at => "Sun Feb 13 18:02:00 +0000 2011",
                        :text => "@testuser2 I've missed the sun so much!",
                        :user => Hashie::Mash.new({
                          :screen_name => "testuser1"})
                        }))
    @tweet2 = Tweet.new(Hashie::Mash.new({:id => 2,
                        :in_reply_to_status_id => nil,
                        :created_at => "Sun Feb 13 18:01:00 +0000 2011",
                        :text => "This weather is so nice. Here comes the sun!",
                        :user => Hashie::Mash.new({
                          :screen_name => "testuser2"})
                        }))
    @tweet1 = Tweet.new(Hashie::Mash.new({:id => 1,
                        :in_reply_to_status_id => nil,
                        :created_at => "Sun Feb 13 18:00:00 +0000 2011",
                        :text => "Watch out, they're predicting snow for this weekend #weather",
                        :user => Hashie::Mash.new({
                          :screen_name => "testuser1"})
                        }))
  end

  describe "#new" do

    it "can be created without any tweets" do
      c = Conversation.new
      c.should be_valid
      c.tweets.should be_empty
    end

    it "can be created with one tweet" do
      c = Conversation.new(@tweet1)
      c.should be_valid
      c.tweets.should eql([@tweet1])
    end

    it "can be created with many tweets" do
      c = Conversation.new(@tweet1, @tweet2)
      c.should be_valid
      c.tweets.should eql([@tweet2, @tweet1])
    end
  end

  describe "#tweets" do
    it "returns tweets in reverse chronological order" do
      c = Conversation.new(@tweet1, @tweet2)
      c.tweets.should eql([@tweet2, @tweet1])
      c2 = Conversation.new(@tweet2, @tweet1)
      c2.tweets.should eql([@tweet2, @tweet1])
    end
  end

  describe "#created_at" do
    it "returns the time of the most recent tweet" do
      c = Conversation.new(@tweet1, @tweet2)
      c.created_at.should eql(@tweet2.created_at)
    end
  end

  describe "#add_tweet" do
    it "inserts a tweet into a conversation" do
      c = Conversation.new
      c.add_tweet(@tweet1)
      c.tweets.should eql([@tweet1])
    end
  end

  describe "#include?" do
    before(:each) do
      @con = Conversation.new(@tweet1, @tweet2)
    end

    it "returns true if the tweet is in the conversation" do
      @con.include?(@tweet1).should be_true
      @con.include?(@tweet2).should be_true
    end

    it "returns false if the tweet is not in the conversation" do
      @con.include?(@tweet3).should be_false
    end
  end

  describe "#participants" do
    it "returns the names of the two participants, no particular order" do
      @con = Conversation.new(@tweet1, @tweet2)
      @con.participants.should include("@testuser1")
      @con.participants.should include("@testuser2")
      @con.participants.size.should eql(2)
    end

    it "only returns each user once" do
      @con = Conversation.new(@tweet1, @tweet2, @tweet3)
      @con.participants.should include("@testuser1")
      @con.participants.should include("@testuser2")
      @con.participants.size.should eql(2)
    end
  end

  describe "#topics" do
    it "returns hashtag if present" do
      @con = Conversation.new(@tweet2, @tweet3, @tweet4)
      @con.topics.should eql(["#happiness"])
    end

    it "returns multiple hashtags if present" do
      @con = Conversation.new(@tweet1, @tweet2, @tweet3, @tweet4)
      @con.topics.should include("#happiness")
      @con.topics.should include("#weather")
      @con.topics.size.should eql(2)
    end

    it "returns the most common noun phrase if no hashtags" do
      @con = Conversation.new(@tweet2, @tweet3)
      @con.topics.should eql(["sun"])
    end

    it "should not return the username of a participant" do
      @con = Conversation.new(@tweet2, @tweet5)
      @con.topics.should_not include("@testuser2")
      @con.topics.join(" ").should_not match(/@testuser2/)
    end
  end
end