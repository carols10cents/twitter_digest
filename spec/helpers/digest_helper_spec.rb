require 'spec_helper'

describe DigestHelper do
  describe "digest_tweets" do
    before(:each) do
      @tweet1 = double("tweet", :id => 1, :in_reply_to_status_id_str => nil)
      @tweet2 = double("tweet", :id => 2, :in_reply_to_status_id_str => nil)
      @tweet3 = double("tweet", :id => 3, :in_reply_to_status_id_str => 2)
    end
    
    it "should not modify tweets that aren't in conversations" do
      helper.digest_tweets([@tweet2, @tweet1]).should eql([@tweet2, @tweet1])
    end
    
    it "should group a tweet with what it was in reply to" do
      helper.digest_tweets([@tweet3, @tweet2, @tweet1]).should 
        eql([[@tweet3, @tweet2], @tweet1])
    end
  end
end
