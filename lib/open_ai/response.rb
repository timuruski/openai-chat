require "json"

module OpenAI
  class Response
    attr_reader :http_response

    def initialize(http_response)
      @http_response = http_response
    end

    def [](key)
      body[key]
    end

    def body
      @body ||= parse_body
    end

    private def parse_body
      if http_response.body.is_a?(String)
        JSON.parse(http_response.body)
      else
        {}
      end
    end

    def success?
      http_response.is_a?(Net::HTTPSuccess)
    end
  end
end
