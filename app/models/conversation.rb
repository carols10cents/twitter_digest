require 'engtagger'

class Conversation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :topics, :type

  def initialize(*args)
    @tweets = []
    args.each do |a|
      add_tweet(a)
    end
  end

  def tweets
    @tweets.sort_by{|t| t.created_at}.reverse
  end

  def add_tweet(tweet)
    @tweets << tweet
  end

  def created_at
    tweets.first.created_at
  end

  def participants
    @tweets.collect{|t| t.user[:screen_name] }.uniq
  end

  def topics
    @topics ||= generate_topics
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

  private
  def generate_topics
    all_text  = text_for(@tweets)
    all_words = all_text.split(" ")

    hashtags = all_words.select{|x| x.starts_with?("#")}
    if !hashtags.empty?
      hashtags
    else
      tagger       = EngTagger.new
      tagged_text  = tagger.add_tags(all_text)
      noun_phrases = tagger.get_noun_phrases(tagged_text)
      [noun_phrases.max_by{|p| p[1]}[0]]
    end
  end

  def text_for(tweets)
    tweets_joined = tweets.map(&:text).join(" ")
    tweets_joined.gsub(/#{participants.join("|")}/, "")
  end
end