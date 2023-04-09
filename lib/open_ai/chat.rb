require "io/console"

module OpenAI
  class Chat
    USER_PROMPT = "$ "
    ASSISTANT_PROMPT = "> "
    DEFAULT_MODEL = "gpt-3.5-turbo"

    def self.start
      new.start
    end

    def initialize
      @client = OpenAI::Client.new(model: DEFAULT_MODEL)
    end

    def start
      reset

      $stdout.print(USER_PROMPT)

      loop do
        input = $stdin.gets
        break if input.nil?

        if output = process(input)
          $stdout.print("> ", output, "\n")
          $stdout.print(USER_PROMPT)
        end
      end
    rescue Interrupt
      exit
    end

    private def reset
      @chat_messages = []
      @chat_messages << message("system", "Answer as concisely as possible.")
      @chat_messages << message("system", "Current date: #{Time.now.strftime("%Y-%m-%d")}.")
      # @chat_messages << message("system", "You answer in rhymes.")
    end

    private def process(input)
      input.chomp!

      case input
      when "exit"
        raise Interrupt
      when "reset"
        reset
        "Chat reset!"
      else
        @chat_messages << message("user", input)

        resp = @client.post_chat(@chat_messages)
        if resp.success?
          message = resp.body.dig("choices", 0, "message", "content").strip
          @chat_messages << message("assistant", message)

          message
        else
          error = resp.body.dig("error", "message")
          warn "ERROR: #{error}"
        end
      end
    end

    private def message(role, content)
      {
        "role" => role,
        "content" => content,
      }
    end
  end
end
