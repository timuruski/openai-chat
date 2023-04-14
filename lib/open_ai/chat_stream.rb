module OpenAI
  class ChatStream
    include Enumerable

    CHAT_PATH = "/v1/chat/completions"

    def initialize(client: nil)
      @client = client || OpenAI.client
      @messages = []
    end

    def push(message, role = "user", &block)
      @messages << Message.new(message, role)

      resp = post_chat(@messages.map(&:to_h), &block)
      if resp.success?
        # message = resp.body.dig("choices", 0, "message", "content").strip
        @messages << Message.new(@last_message, "assistant")
      else
        error_msg = resp.body.dig("error", "message")
        raise error_msg
      end

      @messages.last
    end

    private def post_chat(messages, &block)
      @last_message = ""

      params = {
        "model" => OpenAI::CHAT_MODEL,
        "messages" => Array(messages),
        "stream" => true,
      }

      @client.post(CHAT_PATH, params) do |event|
        event.lines("\n\n", chomp: true).each do |line|
          _, data = line.split(": ", 2)

          if data != "[DONE]"
            if content =  JSON.parse(data).dig("choices", 0, "delta", "content")
              yield content
              @last_message << content
            end
          end
        end
      end
    end

    # TODO Merge events properly.
    private def merge_events(events)
      events.flat_map { |event| event.lines("\n\n", chomp: true).map { |line| line.split(": ", 2)[1] } }
    end

    def push!(message, role)
      @messages << Message.new(message, role)
      @messages.last
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
