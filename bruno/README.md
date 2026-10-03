# Reputation Service Bruno collection

Open the repository root as a collection in Bruno and select the `local`
environment. Start the service on port 3001, then run requests `01` through `06`
in order.

Request `01` stores the created record ID in `recordId`; no manual copying is
needed. Use fresh UUIDs in request `01`, or reset the development database, when
repeating the demo because `(run_id, runner_id)` must be unique.
