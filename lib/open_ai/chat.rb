module OpenAI
  class Chat
    include Enumerable

    CHAT_PATH = "/v1/chat/completions"
    DEFAULT_MODEL = "gpt-3.5-turbo"

    attr_reader :client, :model

    def initialize(client: nil, model: DEFAULT_MODEL, base_params: nil)
      @client = client || Client.new(model: model, base_params: base_params)
      @messages = []
    end

    def push(query, role = "user", &block)
      @messages << Message.new(query, role)

      reply, resp = post_chat(@messages.map(&:to_h), &block)
      if resp.success?
        @messages << Message.new(reply, "assistant")
      else
        error_msg = resp.body.dig("error", "message")
        raise error_msg
      end

      @messages.last
    end

    private def post_chat(messages, &block)
      reply = ""
      stream = !!block

      params = {
        "messages" => Array(messages),
        "stream" => stream
      }

      if stream
        reply = ""
        resp = @client.post(CHAT_PATH, params, &handle_stream(reply, block))
      else
        resp = @client.post(CHAT_PATH, params)
        reply = resp.body.dig("choices", 0, "message", "content").strip
      end

      [reply, resp]
    end

    private def handle_stream(reply, block)
      proc do |chunk|
        chunk.lines("\n\n", chomp: true).each do |line|
          _, data = line.split(": ", 2)

          if data != "[DONE]"
            # Sometimes a chunk is yielded before it contains full JSON, subsequent calls
            # replay the same object, so this appears to work correctly.
            json = JSON.parse(data) rescue {}

            if (content = json.dig("choices", 0, "delta", "content"))
              block.yield content
              reply << content
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
