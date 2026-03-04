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
