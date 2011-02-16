require 'spec_helper'
require 'hashie'

describe Tweet do
  
  describe "#new" do
    it "creates a tweet from a twitter API response Hashie::Mash" do
      twitter_response = Hashie::Mash.new({
                           :contributors              => nil,
                           :coordinates               => nil, 
                           :created_at                => "Tue Feb 15 01:56:02 +0000 2011", 
                           :favorited                 => false,
                           :geo                       => nil, 
                           :id                        => 37329254853124096,
                           :id_str                    => "37329254853124096",
                           :in_reply_to_screen_name   => "mrdomino",
                           :in_reply_to_status_id     => 37324216470732800,
                           :in_reply_to_status_id_str => "37324216470732800",
                           :in_reply_to_user_id       => 18031634,
                           :in_reply_to_user_id_str   => "18031634",
                           :place                     => nil,
                           :retweet_count             => 0,
                           :retweeted                 => false,
                           :source                    => "<a href=\"http://itunes.apple.com/us/app/twitter/id409789998?mt=12\" rel=\"nofollow\">Twitter for Mac</a>",
                           :text                      => "@mrdomino That's... weird. I find it the other way around if anything. Three names for map = \"pragmatic\". No namespaces = very impure.",
                           :truncated                 => false,
                           :user                      => Hashie::Mash.new({
                             :contributors_enabled => false,
                             :created_at => "Sun Mar 04 05:12:14 +0000 2007", 
                             :description => "Python, Ruby, and Unix hacker; creator & destroyer of software; aspiring man of maximum practical application; flippancy expert.",
                             :favourites_count => 110,
                             :follow_request_sent => false,
                             :followers_count => 1259,
                             :following => true,
                             :friends_count => 91,
                             :geo_enabled => false,
                             :id => 809685,
                             :id_str => "809685",
                             :is_translator => false,
                             :lang => "en",
                             :listed_count => 120,
                             :location => "Seattle",
                             :name => "Gary Bernhardt",
                             :notifications => false,
                             :profile_background_color => "9ae4e8", 
                             :profile_background_image_url => "http://a3.twimg.com/a/1297446951/images/themes/theme1/bg.png",
                             :profile_background_tile => false,
                             :profile_image_url => "http://a3.twimg.com/profile_images/1170938305/twitter_headshot_normal.png",
                             :profile_link_color => "0000ff",
                             :profile_sidebar_border_color => "87bc44",
                             :profile_sidebar_fill_color => "e0ff92",
                             :profile_text_color => "000000",
                             :profile_use_background_image => true,
                             :protected => false,
                             :screen_name => "garybernhardt",
                             :show_all_inline_media => false,
                             :statuses_count => 10974,
                             :time_zone => "Eastern Time (US & Canada)",
                             :url => "http://blog.extracheese.org",
                             :utc_offset => -18000,
                             :verified => false
                           })
                        })
      Tweet.new(twitter_response).should be_valid
    end
  end
  
  describe "self#digest" do
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
        Tweet.digest([@tweet2, @tweet1]).stream.should eql([@tweet2, @tweet1])
      end

      it "should not group tweets whose replies are not in this batch" do
        Tweet.digest([@tweet3, @tweet2]).stream.should eql([@tweet3, @tweet2])
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
        Tweet.digest([@tweet3, @tweet2, @tweet1]).stream.should eql([
          Conversation.new(@tweet3, @tweet2),
          @tweet1
        ])
      end

      it "should group tweets that are in reply to the same thing" do
        Tweet.digest([@tweet4, @tweet3, @tweet2, @tweet1]).stream.should eql([
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
        Tweet.digest([@tweet4, @tweet3, @tweet2, @tweet1]).stream.should eql([
          Conversation.new(@tweet4, @tweet3, @tweet2, @tweet1)])
      end
    end
  end
end