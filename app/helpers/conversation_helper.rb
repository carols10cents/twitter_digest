module ConversationHelper
  def and_list(items)
    return items[0] if items.size == 1
    list = items[0...-1].join(", ")
    list += " and " + items.last
  end
end