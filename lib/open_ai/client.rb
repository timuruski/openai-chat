require "json"
require "net/http"
require "uri"

module OpenAI
  class Client
    attr_reader :api_key

    def initialize(api_key = nil)
      @api_key = api_key || OpenAI.api_key
    end

    def get_models
      get("/v1/models")
    end

    # POST https://api.openai.com/v1/completions
    def post_completion(prompt)
      params = {
        "model" => OpenAI::DEFAULT_MODEL,
        "prompt" => prompt.to_s,
      }

      post("/v1/completions", params)
    end

    # ---

    def get(path, query = nil)
      url = build_url(path, query)

      http_request(url) do |http|
        http.get(url.path, build_headers)
      end
    end

    def post(path, body = nil)
      url = build_url(path)
      body = JSON.generate(body) if body
      headers = build_headers
      headers["Content-Type"] = "application/json"

      http_request(url) do |http|
        http.post(url.path, body, headers)
      end
    end

    private def build_url(path, query = nil)
      url = URI.parse(BASE_URL)

      url.query = URI.encode_www_form(query) if query
      url.path = File.join(url.path, path)

      url
    end

    def build_headers
      {
        "Authorization" => "Bearer #{api_key}",
      }
    end

    private def http_request(url)
      http_response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https") do |http|
        yield(http) if block_given?
      end

      Response.new(http_response)
    end
  end
end
