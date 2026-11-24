# Postgres

Needs `psql` and a running Postgres. A local install works as is. For Docker: `./infra/up.sh`, then `source infra/env.sh`.

Plan: [roadmap.md](roadmap.md)

## Running a lesson
1. `cd concepts/NN-slug` and read `notes.md`
2. run `./check.sh` once: it creates the lesson's own database (`learn_NN`) and loads the data
3. look around with `psql learn_NN`, try things, then write your fix in `solution.sql`
4. run `./check.sh` again: it reloads the data, applies your `solution.sql`, and prints PASS or FAIL

Each lesson has its own database, so one lesson never wipes another.

## psql tips
- `\d` lists tables, `\d+ name` describes one
- `\x` toggles expanded output (one column per line)
- `\timing` shows how long each query takes
- `\i file.sql` runs a file
- `\e` opens your editor for the current query
