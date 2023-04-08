require "io/console"

module OpenAI
  class Chat
    def self.start
      new.start
    end

    def initialize
      @client = OpenAI::Client.new
    end

    def start
      $stdout.print "$ "

      loop do
        input = $stdin.gets
        break if input.nil?

        if output = handle(input)
          $stdout.print("> ", output, "\n")
          $stdout.print("$ ")
        end
      end
    rescue Interrupt
      exit
    end

    def handle(input)
      return if input.nil?

      input.chomp!

      case input
      when "exit"
        exit
      else
        resp = @client.post_completion(input)
        resp.body.dig("choices", 0, "text").strip
      end
    end
  end
end
