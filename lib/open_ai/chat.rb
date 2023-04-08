require "io/console"

module OpenAI
  class Chat
    def self.start
      new.start
    end

    def initialize
      @client = OpenAI::Client.new(model: "gpt-3.5-turbo")
      @messages = [
        {
          "role" => "system",
          "content" => "You are a helpful assistant.",
        }
      ]
    end

    def start
      $stdout.print "$ "

      loop do
        input = $stdin.gets
        break if input.nil?

        if output = handle_message(input)
          $stdout.print("> ", output, "\n")
          $stdout.print("$ ")
        end
      end
    rescue Interrupt
      exit
    end

    def handle_message(input)
      input.chomp!

      case input
      when "exit"
        exit
      else
        @messages << {
          "role" => "user",
          "content" => input,
        }

        resp = @client.post_chat(@messages)
        if resp.success?
          message = resp.body.dig("choices", 0, "message")
          @messages << message

          message["content"].strip
        else
          error = resp.body.dig("error", "message")
          warn "ERROR: #{error}"
        end
      end
    end
  end
end
