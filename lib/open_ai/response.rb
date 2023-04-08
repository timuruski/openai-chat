require "json"

module OpenAI
  class Response
    attr_reader :http_response

    def initialize(http_response)
      @http_response = http_response
    end

    def body
      @body ||= JSON.parse(http_response.body)
    end

    def success?
      http_response.code == "200"
    end
  end
end
