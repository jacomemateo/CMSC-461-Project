# CMSC 461 Project

Mateo Jacome, Jason Chen

## Commands for connecting to DB

Starting/Creating DB: `make create_db`

Connecting to DB CMD: `make connect_db`

Shutting down DBL `make shutdown_db`

Getting rid of DB data and schemas: `make nuke_db`

Accessing DB logs: `logs_db`

## How to connect to PGAdmin Dashboard
Go to `http://localhost:5050/` and log in with the following credentials:
```bash
admin@example.com # Email
admin # Password
```

## Smoke test

After the container is running just run `make smoke_test`


## Building Report
Run `cd docs && make build-image` then do `make pdf` to test it out.

Add this to ur vscode user settings if you wanna use the `LaTeX Workshop Extension`
```json
  "latex-workshop.latex.outDir": "build",

  "latex-workshop.latex.tools": [
    {
      "name": "docker-latexmk",
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-v",
        "%DIR%:/work",
        "latex-docker",
        "latexmk",
        "-xelatex",
        "-shell-escape",
        "-interaction=nonstopmode",
        "-file-line-error",
        "-output-directory=build",
        "%DOCFILE%"
      ]
    }
  ],

  "latex-workshop.latex.recipes": [
    {
      "name": "Docker LaTeX",
      "tools": ["docker-latexmk"]
    }
  ]
```