module OpenAI
  class ChatStream
    include Enumerable

    CHAT_PATH = "/v1/chat/completions"
    DEFAULT_MODEL = "gpt-3.5-turbo"

    attr_reader :client, :chunks

    def initialize(client: nil, model: nil)
      @client = client || OpenAI.client
      @model = model || DEFAULT_MODEL

      @chunks = []
      @messages = []
    end

    def push(query, role = "user", &block)
      @messages << Message.new(query, role)

      reply, resp = post_chat(@messages.map(&:to_h), &block)
      if resp.success?
        # message = resp.body.dig("choices", 0, "message", "content").strip
        @messages << Message.new(reply, "assistant")
      else
        error_msg = resp.body.dig("error", "message")
        raise error_msg
      end

      @messages.last
    end

    private def post_chat(messages, &block)
      reply = ""
      @chunks.clear

      params = {
        "model" => @model,
        "messages" => Array(messages),
        "stream" => true
      }

      resp = @client.post(CHAT_PATH, params) do |chunk|
        chunk.lines("\n\n", chomp: true).each do |line|
          @chunks << line
          _, data = line.split(": ", 2)

          if data != "[DONE]"
            json = JSON.parse(data)
            if (content = json.dig("choices", 0, "delta", "content"))
              yield content
              reply << content
            end
          end
        end
      end

      [reply, resp]
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
