# Postgres Roadmap

For: an experienced developer (4 years) who knows MongoDB and basic SQL. Skips CREATE TABLE and basic CRUD.
Learn in order. Each lesson is a hands-on problem; see [README.md](README.md) for how to run one. Lessons are built one phase at a time.
Stuck on a term? Look it up in [ROADMAP-2.md](ROADMAP-2.md) (full manual TOC).

## Phase 1: Modeling data the relational way (built)
Setting for the whole phase: Trimly, a chain of hair salons with an online booking app, moving off MongoDB.

| Topic | Lesson |
|---|---|
| schema-first vs schemaless | 01 |
| exact numbers for money, timestamps with time zones | 02 |
| ids that never clash (`serial` vs `uuid`), generated columns | 03 (one problem, two topics) |
| constraints: `NOT NULL`, `CHECK`, `UNIQUE`, `FOREIGN KEY` | 04, 05 (two problems: keeping bad rows out, and what happens on delete) |
| normalization, keeping historical values | 06 |
| range types, rules across rows, concurrent writes | 07 |

- [ ] [01. From documents to tables](concepts/01-documents-to-tables/notes.md): schema-first vs schemaless
- [ ] [02. Choosing types](concepts/02-choosing-types/notes.md): exact numbers for money, timestamps with time zones
- [ ] [03. Ids and derived values](concepts/03-ids-and-derived-values/notes.md): `serial` vs `uuid`, generated columns
- [ ] [04. Constraints keep bad data out](concepts/04-constraints/notes.md): `NOT NULL`, `CHECK`, `UNIQUE`, `FOREIGN KEY`
- [ ] [05. Deleting data](concepts/05-deleting-data/notes.md): what foreign keys do on delete (`CASCADE`, `SET NULL`, refuse)
- [ ] [06. Normalization](concepts/06-normalization/notes.md): anomalies, one fact in one place, keeping historical values
- [ ] [07. No overlapping bookings](concepts/07-no-overlapping-bookings/notes.md): range types, rules across rows, concurrent writes

Not covered yet, on purpose: enums and domains (lesson 04's `CHECK` on status covers the everyday case).

## Phase 2: Query power
- joins done properly (incl. LATERAL)
- CTEs (incl. recursive), data-modifying CTEs
- window functions (`row_number`, `lag`, running totals)
- upsert (`INSERT ... ON CONFLICT`, `RETURNING`) and `MERGE`
- aggregates: `FILTER`, `GROUPING SETS`, `array_agg`, `jsonb_agg`
- set-returning functions (`generate_series`, `unnest`) and arrays

## Phase 3: Performance
- reading `EXPLAIN (ANALYZE, BUFFERS)`
- B-tree indexes: composite order, partial, covering; index-only scans
- GIN / GiST / BRIN: when each
- planner statistics, `ANALYZE`, why the planner picks a sequential scan
- bulk loading with `COPY`
- finding slow queries with `pg_stat_statements`

## Phase 4: Transactions & concurrency
- MVCC, dead rows, `VACUUM` and autovacuum
- isolation levels and the anomalies each one allows
- serialization failures and retries
- row locks: `SELECT ... FOR UPDATE`, `SKIP LOCKED`, deadlocks
- advisory locks

## Phase 5: Beyond relational
- `jsonb`: operators, indexing, querying documents like Mongo
- SQL/JSON path and `JSON_TABLE`
- full-text search and `pg_trgm`
- `pgvector`

## Phase 6: Operations
- migrations without downtime (index builds, column changes)
- `pg_dump` / `pg_restore`, WAL, point-in-time recovery
- streaming replication
- partitioning
- connection pooling (PgBouncer)
- roles, grants, row-level security, schemas and `search_path`

## Capstone
Build Trimly's booking backend end to end on Postgres, using what each phase taught.

Earlier problem-first lessons (double booking, bulk delete, session lookup, index builds) are in `concepts/_archive/v1/`. Their topics come back in Phases 1, 3, 4 and 6.
