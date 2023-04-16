module OpenAI
  class Completion
    def initialize(prompt, n: nil)
      @prompt = prompt
      @n = n || 1
    end

    def to_s
      choices[0]
    end

    def [](i)
      choices[i]
    end

    def choices
      @choices ||= get_choices["choices"].map { |c| c["text"].strip }
    end

    private def get_choices
      params = {
        "n" => @n,
        "model" => OpenAI::DEFAULT_MODEL,
        "prompt" => @prompt.to_s
      }

      OpenAI.client.post("/v1/completions", params)
    end
  end
end
