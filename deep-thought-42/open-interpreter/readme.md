## prompt usage:

```python

import interpreter
import guardrails as gd
import openai

guard = gd.Guard.from_rail(f.name)

interpreter.chat("Plot AAPL and META's normalized stock prices") # Executes a single command
interpreter.chat() # Starts an interactive chat

message = "What operating system are we on?"

for chunk in interpreter.chat(message, display=False, stream=True):
  print(chunk)

interpreter.chat("Add subtitles to all videos in /videos.")

# ... Streams output to your terminal, completes task ...

interpreter.chat("These look great but can you make the subtitles bigger?")

# ...

# restart chat history

interpreter.reset()

# put some guardrails on it:

# Wrap the OpenAI API call with the `guard` object
raw_llm_output, validated_output = guard(
    openai.Completion.create,
    engine="text-davinci-003",
    max_tokens=1024,
    temperature=0.3
)

print(validated_output)

```
