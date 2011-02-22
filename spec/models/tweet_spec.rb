require 'spec_helper'
require 'hashie'

describe Tweet do

  describe "#new" do
    before(:each) do
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
      @tweet1 = Tweet.new(twitter_response)
    end

    it "is valid" do
      @tweet1.should be_valid
    end

    it "should change all screen names to have @ at the beginning" do
      @tweet1.in_reply_to_screen_name.should eql("@mrdomino")
      @tweet1.user.screen_name.should eql("@garybernhardt")
    end
  end
end