# OpenAI Experiment

Just messing around with the OpenAI models.

## Getting Started
Export `OPENAI_API_KEY` then use `bin/chat` to start a chat session.

Use `bin/console` to start an IRB session.

```
$ puts OpenAI::Completion.new("What time is it?")
> It is  10:50 PM EST right now.

$ puts OpenAI::Completion.new("How many cents in a dollar?")
> There are 100 cents in a dollar.
```

