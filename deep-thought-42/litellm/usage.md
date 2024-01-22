```python

    from litellm import completion
    import os

    messages = [{ "content": "Hello, how are you?","role": "user"}]
    # openai call
    response = completion(model="gpt-3.5-turbo", messages=messages)
    # cohere call
    response = completion(model="command-nightly", messages=messages)
    print(response)

```
