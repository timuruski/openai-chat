module OpenAI
  class ChatLoop
    USER_PROMPT = "$ "
    ASSISTANT_PROMPT = "  "
    SYSTEM_MESSAGE = /^\/system (.+)$/

    def self.start
      new.start
    end

    def start
      reset

      $stdout.print(USER_PROMPT)

      loop do
        input = $stdin.gets
        break if input.nil?

        if output = process(input)
          $stdout.print(ASSISTANT_PROMPT, output, "\n")
          $stdout.print(USER_PROMPT)
        end
      end
    rescue Interrupt
      exit
    end

    private def reset
      @chat = Chat.new
      @chat.push!("Answer as concisely as possible.", "system")
      @chat.push!("Current date: #{Time.now.strftime("%Y-%m-%d")}.", "system")
      # @chat.push!("You answer in rhymes.", "system")
    end

    private def process(input)
      input.chomp!

      case input
      when "exit"
        raise Interrupt
      when "debug"
        debug
        "Done debugging!"
      when "reset"
        reset
        "Chat reset!"
      when SYSTEM_MESSAGE
        @chat.push!($1, "system")
        "OK: #{@chat.last.content}"
      else
        @chat.push(input, "user")
        @chat.last.content
      end
    rescue error
      warn "ERROR: #{error}"
    end

    private def debug
      binding.irb
    end
  end
end
