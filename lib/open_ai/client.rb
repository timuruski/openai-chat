require "json"
require "net/http"
require "uri"

module OpenAI
  class Client
    attr_reader :api_key, :model

    def initialize(api_key: nil, model: nil)
      @api_key = api_key || OpenAI.api_key
      @base_params = {
        "model" => model || OpenAI::DEFAULT_MODEL
      }
    end

    def get(path, query = nil, &block)
      url = build_url(path, query)

      response = request { |http| http.get(url.path, build_headers, &block) }
      Response.new(response)
    end

    def post(path, params = nil, &block)
      url = build_url(path)
      headers = build_headers
      headers["Content-Type"] = "application/json"

      data = JSON.generate(@base_params.merge(params.to_h))

      response = request { |http| http.post(url.path, data, headers, &block) }
      Response.new(response)
    end

    # This manages incomplete HTTP connections when streaming chat is interrupted.
    # It is not thread safe.
    private def request(&block)
      reset_http unless @finished
      @http ||= start_http

      response = yield @http
      @finished = true

      response
    end

    private def reset_http
      @http.finish if @http && @http.started?
      @http = nil
    end

    private def start_http
      url = URI.parse(BASE_URL)
      Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https")
    end

    private def build_url(path, query = nil)
      url = URI.parse(BASE_URL)

      url.query = URI.encode_www_form(query) if query
      url.path = File.join(url.path, path)

      url
    end

    private def build_headers
      {
        "Authorization" => "Bearer #{api_key}"
      }
    end
  end
end
