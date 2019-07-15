# Monaco language client & Omnisharp language server demo

Running the demo:
```
docker build -t monaco-languageclient-omnisharp-lsp .
docker run --rm -p 3000:3000 monaco-languageclient-omnisharp-lsp
```

The monaco editor will be accessable at `http://localhost:3000`
