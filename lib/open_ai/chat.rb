module OpenAI
  class Chat
    include Enumerable

    DEFAULT_MODEL = "gpt-3.5-turbo"
    CHAT_PATH = "/v1/chat/completions"

    Message = Struct.new(:content, :role) do
      def to_s
        content
      end

      def to_h
        {
          "role" => role,
          "content" => content,
        }
      end
    end

    def initialize(client: nil)
      @client = client || OpenAI.client
      @messages = []
    end

    def push(message, role)
      @messages << Message.new(message, "user")

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
        "model" => DEFAULT_MODEL,
        "messages" => Array(messages),
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
