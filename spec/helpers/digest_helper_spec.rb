require 'spec_helper'
require 'hashie'

describe DigestHelper do
  describe "#digest_tweets" do
    context "no conversations" do
      before(:each) do
        @tweet3 = Hashie::Mash.new({:id => 3,
                            :in_reply_to_status_id => 9000,
                            :created_at => "Sun Feb 13 18:02:00 +0000 2011"})
        @tweet2 = Hashie::Mash.new({:id => 2,
                            :in_reply_to_status_id => nil,
                            :created_at => "Sun Feb 13 18:01:00 +0000 2011"})
        @tweet1 = Hashie::Mash.new({:id => 1,
                            :in_reply_to_status_id => nil,
                            :created_at => "Sun Feb 13 18:00:00 +0000 2011"})
      end

      it "should not group tweets that aren't in conversations" do
        helper.digest_tweets([@tweet2, @tweet1]).should eql([@tweet2, @tweet1])
      end

      it "should not group tweets whose replies are not in this batch" do
        helper.digest_tweets([@tweet3, @tweet2]).should eql([@tweet3, @tweet2])
      end
    end

    context "one level of replies" do
      before(:each) do
        @tweet4 = Hashie::Mash.new({:id => 4,
                            :in_reply_to_status_id => 2,
                            :created_at => "Sun Feb 13 18:03:00 +0000 2011"})
        @tweet3 = Hashie::Mash.new({:id => 3,
                            :in_reply_to_status_id => 2,
                            :created_at => "Sun Feb 13 18:02:00 +0000 2011"})
        @tweet2 = Hashie::Mash.new({:id => 2,
                            :in_reply_to_status_id => nil,
                            :created_at => "Sun Feb 13 18:01:00 +0000 2011"})
        @tweet1 = Hashie::Mash.new({:id => 1,
                            :in_reply_to_status_id => nil,
                            :created_at => "Sun Feb 13 18:00:00 +0000 2011"})
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

    context "multilevel conversations" do
      before(:each) do
        @tweet4 = Hashie::Mash.new({:id => 37329254853124096,
                            :in_reply_to_status_id => 37324216470732800,
                            :created_at => "Tue Feb 15 01:56:02 +0000 2011"})
        @tweet3 = Hashie::Mash.new({:id => 37324216470732800,
                            :in_reply_to_status_id => 37282744786624512,
                            :created_at => "Tue Feb 15 01:36:01 +0000 2011"})
        @tweet2 = Hashie::Mash.new({:id => 37324098896007168,
                            :in_reply_to_status_id => 37282744786624512,
                            :created_at => "Tue Feb 15 01:35:33 +0000 2011"})
        @tweet1 = Hashie::Mash.new({:id => 37282744786624512,
                            :in_reply_to_status_id => nil,
                            :created_at => "Tue Feb 15 01:30:33 +0000 2011"})
      end

      it "should all be one conversation" do
        helper.digest_tweets([@tweet4, @tweet3, @tweet2, @tweet1]).should eql([
          {:conversation => [@tweet4, @tweet3, @tweet2, @tweet1],
           :ids          => [@tweet4.id, @tweet3.id, @tweet2.id, @tweet1.id]
          }
        ])
      end
    end
  end
end