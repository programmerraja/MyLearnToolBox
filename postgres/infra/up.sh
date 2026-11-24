#!/usr/bin/env bash
# Start local Postgres (needs Docker). Stop: ./up.sh down   Wipe data: ./up.sh down -v
cd "$(dirname "$0")" && docker compose "${@:-up -d}"
