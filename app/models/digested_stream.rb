class DigestedStream
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize
    @stream = []
  end

  def size
    @stream.size
  end

  def empty?
    @stream.empty?
  end

  def stream
    @stream.sort_by{|i| i.created_at}.reverse
  end

  def <<(item)
    @stream << item
  end

  def delete(item)
    @stream.delete(item)
  end

  def include?(tweet)
    @stream.any? do |i|
      (i.respond_to?(:include?) && i.include?(tweet)) ||
        i.eql?(tweet)
    end
  end

  def find_conversation_by_tweet(tweet)
    @stream.find{|i| (i.respond_to?(:include?) && i.include?(tweet)) }
  end

  def persisted?
    false
  end
end