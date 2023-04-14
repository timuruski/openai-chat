module OpenAI
  Message = Struct.new(:content, :role) do
    def to_s
      content
    end

    def to_h
      {
        "role" => role,
        "content" => content,
      }
    end
  end
end
