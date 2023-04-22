module OpenAI
  class << self
    attr_accessor :api_key
  end

  BASE_URL = "https://api.openai.com/"
  DEFAULT_MODEL = "text-davinci-003"

  autoload :Chat, "open_ai/chat"
  autoload :ChatSession, "open_ai/chat_session"
  autoload :Client, "open_ai/client"
  autoload :Completion, "open_ai/completion"
  autoload :Message, "open_ai/message"
  autoload :Response, "open_ai/response"

  def self.client
    @client ||= Client.new
  end

  def self.chat_client
    @chat_client ||= Client.new(model: Chat::DEFAULT_MODEL)
  end

  def self.complete(prompt)
    resp = client.post_completion(prompt)
    resp.body.dig("choices", 0, "text").strip
  end
end
