class AddLastTweetSeenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_tweet_seen, :string
  end

  def self.down
    remove_column :users, :last_tweet_seen
  end
end
