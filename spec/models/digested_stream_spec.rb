require 'spec_helper'
require 'hashie'

describe DigestedStream do
  before(:each) do
    @tweet4 = Tweet.new(Hashie::Mash.new({:id => 4,
                        :in_reply_to_status_id => 2,
                        :created_at => "Sun Feb 13 18:03:00 +0000 2011"}))
    @tweet3 = Tweet.new(Hashie::Mash.new({:id => 3,
                        :in_reply_to_status_id => 9000,
                        :created_at => "Sun Feb 13 18:02:00 +0000 2011"}))
    @tweet2 = Tweet.new(Hashie::Mash.new({:id => 2,
                        :in_reply_to_status_id => nil,
                        :created_at => "Sun Feb 13 18:01:00 +0000 2011"}))
    @tweet1 = Tweet.new(Hashie::Mash.new({:id => 1,
                        :in_reply_to_status_id => nil,
                        :created_at => "Sun Feb 13 18:00:00 +0000 2011"}))
  end


  describe "#new" do
    it "should be valid" do
      d = DigestedStream.new
      d.should be_valid
    end
  end
  
  describe "#<<" do    
    it "accepts a tweet" do
      d = DigestedStream.new
      d << @tweet1
      d.stream.should eql([@tweet1])      
    end
    
    it "accepts a conversation" do
      d = DigestedStream.new
      c = Conversation.new(@tweet2, @tweet3)
      d << c
      d.stream.should eql([c])    
    end
  end

  describe "#stream" do
    it "should have tweets and conversations in reverse chronological order" do
      d = DigestedStream.new
      d << @tweet1
      d << @tweet4
      c = Conversation.new(@tweet2, @tweet3)
      d << c
      d.stream.should eql([@tweet4, c, @tweet1])
    end
  end
  
  describe "#find_conversation_by_tweet" do
    before(:each) do
      @d = DigestedStream.new
      @d << @tweet1
      @c = Conversation.new(@tweet2, @tweet3)
      @d << @c    
    end
    
    it "should return the conversation that contains that tweet" do
      @d.find_conversation_by_tweet(@tweet2).should eql(@c)
    end
    
    it "should return nil if there is not a conversation that contains that tweet" do
      @d.find_conversation_by_tweet(@tweet1).should be_nil
      @d.find_conversation_by_tweet(@tweet4).should be_nil
    end
  end
    
  describe "#include?" do
    it "should look in both individual tweets and conversations for a tweet" do
      d = DigestedStream.new
      d << @tweet1
      c = Conversation.new(@tweet2, @tweet3)
      d << c
      d.include?(@tweet1).should be_true
      d.include?(@tweet2).should be_true
      d.include?(@tweet3).should be_true
      d.include?(@tweet4).should be_false
    end
  end  
end