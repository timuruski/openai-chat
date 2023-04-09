require "json"
require "net/http"
require "uri"

module OpenAI
  class Client
    attr_reader :api_key, :model

    def initialize(api_key = nil, model: nil)
      @api_key = api_key || OpenAI.api_key
      @base_params = {
        "model" => model || OpenAI::DEFAULT_MODEL,
      }

      url = URI.parse(BASE_URL)
      @http = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == "https")
    end

    def get_models
      get("/v1/models")
    end

    # POST https://api.openai.com/v1/completions
    def post_completion(prompt)
      params = {
        "model" => model,
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

    def post(path, params = nil)
      url = build_url(path)
      headers = build_headers
      headers["Content-Type"] = "application/json"

      data = JSON.generate(@base_params.merge(params.to_h))

      http_request(url) do |http|
        http.post(url.path, data, headers)
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
      http_response = yield(@http)

      Response.new(http_response)
    end
  end
end
