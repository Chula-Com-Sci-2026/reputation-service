# Reputation Service

Reputation Service is a REST microservice for the **Can't Run Alone** platform. It owns attendance, ratings, reliability, and running-history data produced after a run. This repository currently implements the first Deliverable 3 vertical slice: CRUD operations for a runner's completed-run records.

## Current scope

The implemented `RunningRecord` resource stores:

- the run and runner UUIDs;
- distance in metres;
- duration in seconds;
- the time the run occurred; and
- optional notes.

Distance and duration must be positive. A runner can have only one record for a particular run.

Planned capabilities such as attendance confirmation, participant ratings, review summaries, organizer reliability, Kafka event handling, and JWT authorization are not implemented yet.

## Technology

- Ruby 3.4.6
- Rails 8.1.4 in API-only mode
- PostgreSQL 16
- Minitest
- Docker Compose

## REST API

Base path: `/api/v1`

| Method | Path | Purpose |
| --- | --- | --- |
| `POST` | `/running_records` | Create a running record |
| `GET` | `/running_records` | List records, newest first |
| `GET` | `/running_records?runner_id={uuid}` | List one runner's records |
| `GET` | `/running_records/{id}` | Read one record |
| `PATCH` | `/running_records/{id}` | Update a record |
| `DELETE` | `/running_records/{id}` | Delete a record |
| `GET` | `/up` | Rails health check |

Validation failures use a consistent JSON error envelope and return HTTP `422`. Missing records return HTTP `404`.

## Run locally

Docker and Docker Compose are the only host requirements.

```bash
docker compose build api
docker compose run --rm api bin/rails db:prepare
docker compose up api
```

The API is available at `http://localhost:3001`.

Create a record:

```bash
curl --request POST http://localhost:3001/api/v1/running_records \
  --header 'Content-Type: application/json' \
  --data '{
    "running_record": {
      "run_id": "11111111-1111-4111-8111-111111111111",
      "runner_id": "22222222-2222-4222-8222-222222222222",
      "distance_meters": 5000,
      "duration_seconds": 1800,
      "occurred_at": "2026-09-28T12:00:00Z",
      "notes": "Steady evening run"
    }
  }'
```

List records:

```bash
curl http://localhost:3001/api/v1/running_records
```

Stop the service without deleting its database volume:

```bash
docker compose down
```

## Test and quality checks

Prepare the test database once, then run the tests and style checker:

```bash
docker compose run --rm -e RAILS_ENV=test api bin/rails db:prepare
docker compose run --rm -e RAILS_ENV=test api bin/rails test
docker compose run --rm --no-deps api bin/rubocop
```

The test suite covers model validation, create, list, read, update, delete, invalid input, and missing records.

## Repository boundary

This service owns its PostgreSQL schema. Other services must use its REST API or versioned domain events rather than reading its database directly. The React frontend should access it through the API Gateway/BFF, not call this internal service directly.
