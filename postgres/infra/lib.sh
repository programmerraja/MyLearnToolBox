#!/usr/bin/env bash
# Shared by every lesson's check.sh. Needs psql and a running Postgres.
# Local Postgres: nothing to set up. Docker: ./infra/up.sh, then `source infra/env.sh`.
export PGDATABASE="${PGDATABASE:-learn}"
export PGOPTIONS="-c client_min_messages=warning"  # hide "table does not exist, skipping" notices
psql postgres -Atc "select 1 from pg_database where datname = '$PGDATABASE'" | grep -q 1 || createdb "$PGDATABASE"
# Times in the lessons are written in UTC; make psql show them that way for this database.
psql postgres -qc "ALTER DATABASE \"$PGDATABASE\" SET timezone TO 'UTC'"

FAILED=0
pass() { echo "PASS: $*"; }
fail() { echo "FAIL: $*"; FAILED=1; }
lt() { awk -v a="$1" -v b="$2" 'BEGIN { exit !(a < b) }'; }  # lt 3 5 -> true
# Execution time in ms of EXPLAIN ANALYZE for the SQL file $1, run inside a rolled-back transaction.
explain_ms() {
  { echo "BEGIN; EXPLAIN (ANALYZE)"; cat "$1"; echo "ROLLBACK;"; } | psql -qAt | awk '/Execution Time/ { print $3 }'
}
