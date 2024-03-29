require "readline"
require "yaml"

module OpenAI
  class ChatSession
    USER_PROMPT = "> "
    ASSISTANT_PROMPT = ""
    SYSTEM_MESSAGE = /^\/system (.+)$/

    attr_reader :chat

    def initialize(log_path: nil, base_params: nil)
      @log_path = File.expand_path(log_path) if log_path
      @base_params = base_params
    end

    def start(&block)
      reset

      loop do
        input = Readline.readline(USER_PROMPT)

        break if input.nil?
        input.chomp!

        if (output = process(input, &block))
          $stdout.print(ASSISTANT_PROMPT, output, "\n")
        end
      rescue Interrupt
        # Trap ^C presses
        $stdout.print "\n"
      end
    end

    private def process(input, &block)
      case input
      when ""
        nil
      when "exit"
        dump(@log_path) if @log_path
        exit
      when "/debug"
        debug
        "Done debugging!"
      when "/reset"
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
        query(input, &block)
        $stdout.print("\n")
        nil
      end
    rescue => error
      warn "ERROR: #{error}"
    end

    def query(message, &block)
      if block
        @chat.push(message, "user", &block)
        $stdout.print("\n")
      else
        $stdout.print(@chat.push(message, "user"), "\n")
      end
    # rescue Interrupt
    #   binding.irb
    end

    def reset
      @chat = Chat.new(base_params: @base_params)
      if @log_path
        load(@log_path)
      else
        @chat.push!("Answer as concisely as possible.", "system")
        # @chat.push!("Current date: #{Time.now.strftime("%Y-%m-%d")}.", "system")
        # @chat.push!("You answer in rhymes.", "system")
      end
    end

    def load(path)
      return unless File.exist?(path)

      @chat = Chat.new

      chat_log = YAML.load(File.read(path)).to_a
      chat_log.each do |msg|
        @chat.push!(msg["content"], msg["role"])
      end
    end

    def dump(path)
      chat_log = YAML.dump(@chat.to_a)
      File.write(path, chat_log)
    end

    private def debug
      binding.irb
    end
  end
end
