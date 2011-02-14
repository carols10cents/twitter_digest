require 'spec_helper'

describe DigestHelper do
  describe "#digest_tweets" do
    before(:each) do
      #created_at = Sun Feb 13 18:22:56 +0000 2011
      @tweet1 = double("tweet1",
                       :id => 1,
                       :in_reply_to_status_id_str => nil,
                       :created_at => "Sun Feb 13 18:00:00 +0000 2011")
      @tweet2 = double("tweet2",
                       :id => 2,

                       :in_reply_to_status_id_str => nil,
                       :created_at => "Sun Feb 13 18:01:00 +0000 2011")
      @tweet3 = double("tweet3",
                       :id => 3,
                       :in_reply_to_status_id_str => 2,
                       :created_at => "Sun Feb 13 18:02:00 +0000 2011")
      @tweet4 = double("tweet4",
                       :id => 4,
                       :in_reply_to_status_id_s       tr => 2,
                       :created_at => "Sun Feb 13 18:03:00 +0000 2011")
    end

    it "should not group tweets that aren't in conversations" do
      helper.digest_tweets([@tweet2, @tweet1]).should eql([@tweet2, @tweet1])
    end

    it "should group a tweet with what it was in reply to" do
      helper.digest_tweets([@tweet3, @tweet2, @tweet1]).should eql([
        {:conversation => [@tweet3, @tweet2],
         :ids          => [@tweet3.id, @tweet2.id]
        },
        @tweet1
      ])
    end

    it "should group tweets that are in reply to the same thing and order by time" do
      helper.digest_tweets([@tweet4, @tweet3, @tweet2, @tweet1]).should eql([
        {:conversation => [@tweet4, @tweet3, @tweet2],
         :ids          => [@tweet4.id, @tweet3.id, @tweet2.id]
        },
        @tweet1
      ])
    end
  end
end
