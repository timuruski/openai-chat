module OpenAI
  class << self
    attr_accessor :api_key
  end

  BASE_URL = "https://api.openai.com/"
  # DEFAULT_MODEL = "gpt-3.5-turbo"
  DEFAULT_MODEL = "text-davinci-003"
  CHAT_MODEL = "gpt-3.5-turbo"

  autoload :Chat, "open_ai/chat"
  autoload :Client, "open_ai/client"
  autoload :Response, "open_ai/response"

  def self.client
    @client ||= Client.new
  end

  def self.chat_client
    @chat_client ||= Client.new(model: CHAT_MODEL)
  end

  def self.complete(prompt)
    resp = client.post_completion(prompt)
    resp.body.dig("choices", 0, "text").strip
  end
end
