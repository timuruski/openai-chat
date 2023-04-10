require "yaml"

module OpenAI
  class ChatLoop
    USER_PROMPT = "$ "
    ASSISTANT_PROMPT = "  "
    SYSTEM_MESSAGE = /^\/system (.+)$/

    def initialize(log_path: nil)
      @log_path = File.expand_path(log_path) if log_path
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

    def reset
      @chat = Chat.new
      if @log_path
        load(@log_path)
      else
        @chat.push!("Answer as concisely as possible.", "system")
        @chat.push!("Current date: #{Time.now.strftime("%Y-%m-%d")}.", "system")
        # @chat.push!("You answer in rhymes.", "system")
      end
    end

    def load(path)
      @chat = Chat.new

      chat_log = YAML.load File.read(path)
      chat_log.each do |msg|
        @chat.push!(msg["content"], msg["role"])
      end
    end

    def dump(path)
      chat_log = YAML.dump(@chat.to_a)
      File.write(path, chat_log)
    end

    private def process(input)
      input.chomp!

      case input
      when "exit"
        dump(@log_path) if @log_path
        exit
      when "debug"
        debug
        "Done debugging!"
      when "reset"
        reset
        "> Chat reset!"
      when "/dump"
        dump(@log_path) if @log_path
        "> Chat log dumped!"
      when "/load"
        load(@log_path) if @log_path
        "> Chat log loaded!"
      when SYSTEM_MESSAGE
        @chat.push!($1, "system")
        "OK: #{@chat.last.content}"
      else
        @chat.push(input, "user")
        @chat.last.content
      end
    rescue => error
      warn "ERROR: #{error}"
    end

    private def debug
      binding.irb
    end
  end
end
