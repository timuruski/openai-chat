module OpenAI
  class Chat
    include Enumerable

    CHAT_PATH = "/v1/chat/completions"

    attr_reader :client

    def initialize(client: nil)
      @client = client || OpenAI.client
      @messages = []
    end

    def push(message, role = "user")
      @messages << Message.new(message, role)

      resp = post_chat(@messages.map(&:to_h))
      if resp.success?
        message = resp.body.dig("choices", 0, "message", "content").strip
        @messages << Message.new(message, "assistant")
      else
        error_msg = resp.body.dig("error", "message")
        raise error_msg
      end

      @messages.last
    end

    def push!(message, role)
      @messages << Message.new(message, role)
      @messages.last
    end

    private def post_chat(messages)
      params = {
        "model" => OpenAI::CHAT_MODEL,
        "messages" => Array(messages)
      }

      @client.post(CHAT_PATH, params)
    end

    def last
      @messages.last
    end

    def each(&block)
      @messages.each(&block)
    end

    def to_a
      @messages.map(&:to_h)
    end
  end
end
