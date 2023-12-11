```python

    # https://docs.activeloop.ai/quickstart
    from deeplake.core.vectorstore import VectorStore
    import openai
    import os

    os.environ['OPENAI_API_KEY'] = <OPENAI_API_KEY>
    source_text = 'file.txt'
    vector_store_path = 'file-analyzed_deeplake'

    with open(source_text, 'r') as f:
        text = f.read()

    CHUNK_SIZE = 1000
    chunked_text = [text[i:i+1000] for i in range(0,len(text), CHUNK_SIZE)]
    def embedding_function(texts, model="text-embedding-ada-002"):
 
       if isinstance(texts, str):
           texts = [texts]

       texts = [t.replace("\n", " ") for t in texts]
       return [data['embedding']for data in openai.Embedding.create(input = texts, model=model)['data']]
    vector_store = VectorStore(
        path = vector_store_path,
    )

    vector_store.add(text = chunked_text, 
                     embedding_function = embedding_function, 
                     embedding_data = chunked_text,
                     metadata = [{"source": source_text}]*len(chunked_text))
```
