require 'spec_helper'

describe "TwitterDigest::DigestionLogic#digest" do
  context "no conversations" do
    before(:each) do
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

    it "should not group tweets that aren't in conversations" do
      TwitterDigest::DigestionLogic
        .digest([@tweet2, @tweet1]).stream.should eql([@tweet2, @tweet1])
    end

    it "should not group tweets whose replies are not in this batch" do
      TwitterDigest::DigestionLogic
        .digest([@tweet3, @tweet2]).stream.should eql([@tweet3, @tweet2])
    end
  end

  context "one level of replies" do
    before(:each) do
      @tweet4 = Tweet.new(Hashie::Mash.new({:id => 4,
                          :in_reply_to_status_id => 2,
                          :created_at => "Sun Feb 13 18:03:00 +0000 2011"}))
      @tweet3 = Tweet.new(Hashie::Mash.new({:id => 3,
                          :in_reply_to_status_id => 2,
                          :created_at => "Sun Feb 13 18:02:00 +0000 2011"}))
      @tweet2 = Tweet.new(Hashie::Mash.new({:id => 2,
                          :in_reply_to_status_id => nil,
                          :created_at => "Sun Feb 13 18:01:00 +0000 2011"}))
      @tweet1 = Tweet.new(Hashie::Mash.new({:id => 1,
                          :in_reply_to_status_id => nil,
                          :created_at => "Sun Feb 13 18:00:00 +0000 2011"}))
    end

    it "should group a tweet with what it was in reply to" do
      TwitterDigest::DigestionLogic
        .digest([@tweet3, @tweet2, @tweet1]).stream.should eql([
          Conversation.new(@tweet3, @tweet2),
          @tweet1
        ])
    end

    it "should group tweets that are in reply to the same thing" do
      TwitterDigest::DigestionLogic
        .digest([@tweet4, @tweet3, @tweet2, @tweet1]).stream.should eql([
          Conversation.new(@tweet4, @tweet3, @tweet2),
          @tweet1
        ])
    end
  end

  context "multilevel conversations" do
    before(:each) do
      @tweet4 = Tweet.new(Hashie::Mash.new({:id => 37329254853124096,
                          :in_reply_to_status_id => 37324216470732800,
                          :created_at => "Tue Feb 15 01:56:02 +0000 2011"}))
      @tweet3 = Tweet.new(Hashie::Mash.new({:id => 37324216470732800,
                          :in_reply_to_status_id => 37282744786624512,
                          :created_at => "Tue Feb 15 01:36:01 +0000 2011"}))
      @tweet2 = Tweet.new(Hashie::Mash.new({:id => 37324098896007168,
                          :in_reply_to_status_id => 37282744786624512,
                          :created_at => "Tue Feb 15 01:35:33 +0000 2011"}))
      @tweet1 = Tweet.new(Hashie::Mash.new({:id => 37282744786624512,
                          :in_reply_to_status_id => nil,
                          :created_at => "Tue Feb 15 01:30:33 +0000 2011"}))
    end

    it "should all be one conversation" do
      TwitterDigest::DigestionLogic
        .digest([@tweet4, @tweet3, @tweet2, @tweet1]).stream.should eql([
          Conversation.new(@tweet4, @tweet3, @tweet2, @tweet1)
        ])
    end
  end

  context "replies to user, not status" do
    before(:each) do
      @tweet6 = Tweet.new(Hashie::Mash.new({
                  :id                      => 6,
                  :user                    => Hashie::Mash.new({
                                                :id          => 12,
                                                :screen_name => "testuser12"
                                              }),
                  :in_reply_to_screen_name => "testuser11",
                  :in_reply_to_status_id   => 5,
                  :created_at              => "Sun Feb 13 18:05:00 +0000 2011"
                }))
      @tweet5 = Tweet.new(Hashie::Mash.new({
                  :id                      => 5,
                  :user                    => Hashie::Mash.new({
                                                :id          => 11,
                                                :screen_name => "testuser11"
                                              }),
                  :in_reply_to_screen_name => nil,
                  :in_reply_to_status_id   => nil,
                  :created_at              => "Sun Feb 13 18:04:00 +0000 2011"
                }))
      @tweet4 = Tweet.new(Hashie::Mash.new({
                  :id                      => 4,
                  :user                    => Hashie::Mash.new({
                                                :id          => 11,
                                                :screen_name => "testuser11"
                                              }),
                  :in_reply_to_screen_name => "testuser12",
                  :in_reply_to_status_id   => nil,
                  :created_at              => "Sun Feb 13 18:03:00 +0000 2011"
                }))
      @tweet3 = Tweet.new(Hashie::Mash.new({
                  :id                      => 3,
                  :user                    => Hashie::Mash.new({
                                                :id          => 12,
                                                :screen_name => "testuser12"
                                              }),
                  :in_reply_to_screen_name => "testuser11",
                  :in_reply_to_status_id   => 2,
                  :created_at              => "Sun Feb 13 18:02:00 +0000 2011"
                }))
      @tweet2 = Tweet.new(Hashie::Mash.new({
                  :id                      => 2,
                  :user                    => Hashie::Mash.new({
                                                :id          => 11,
                                                :screen_name => "testuser11"
                                              }),
                  :in_reply_to_screen_name => nil,
                  :in_reply_to_status_id   => nil,
                  :created_at              => "Sun Feb 13 18:01:00 +0000 2011"
                }))
      @tweet1 = Tweet.new(Hashie::Mash.new({
                  :id                      => 1,
                  :user                    => Hashie::Mash.new({
                                                :id => 10,
                                                :screen_name => "testuser10"
                                              }),
                  :in_reply_to_screen_name => "testuser11",
                  :in_reply_to_status_id   => nil,
                  :created_at              => "Sun Feb 13 18:00:00 +0000 2011"
                }))
    end

    it "leaves the tweet alone if no conversation with these 2 users exists" do
      TwitterDigest::DigestionLogic
        .digest([@tweet3, @tweet2, @tweet1]).stream.should eql([
          Conversation.new(@tweet3, @tweet2),
          @tweet1
        ])
    end

    it "adds the tweet to an existing conversation with these 2 users" do
      TwitterDigest::DigestionLogic
        .digest([@tweet4, @tweet3, @tweet2]).stream.should eql([
          Conversation.new(@tweet4, @tweet3, @tweet2)
        ])
    end

    it "creates one big conversation if there are >1 conversations with these 2 users" do
      TwitterDigest::DigestionLogic
        .digest([@tweet6, @tweet5, @tweet4, @tweet3, @tweet2])
        .stream.should eql([Conversation.new(@tweet6, @tweet5, @tweet4, @tweet3, @tweet2)])
    end
  end
end