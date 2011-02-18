class Conversation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(*args)
    @tweets = []
    args.each do |a|
      add_tweet(a)
    end
  end

  def tweets
    @tweets
  end

  def add_tweet(tweet)
    @tweets << tweet
    @tweets.sort_by!{|t| t.created_at}.reverse!
  end

  def created_at
    @tweets.first.created_at
  end

  def participants
    @tweets.collect{|t| t.user.screen_name}.uniq
  end

  def topic
    frequencies = Hash.new(0)
    @tweets.each do |tweet|
      tweet.text.split(" ").each do |word|
        frequencies[word] += 1 unless word.start_with?("@")
      end
    end
    return frequencies.max_by{|f| f[1]}[0]
  end

  def include?(tweet)
    @tweets.include?(tweet)
  end

  def eql?(other_conversation)
    self.class.eql?(other_conversation.class) &&
      self.tweets.eql?(other_conversation.tweets)
  end

  alias == eql?

  def persisted?
    false
  end

end