# Only for the Docker setup: `source infra/env.sh` so psql and the lesson checks talk to the container.
export PGHOST=localhost PGPORT=5432 PGUSER=learn PGPASSWORD=learn PGDATABASE=learn
