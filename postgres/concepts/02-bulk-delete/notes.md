# 02 Bulk delete

**Problem**
A nightly cleanup job deletes finished nodes that are older than a year. It takes several seconds, and the team already added an index on `created` that didn't help. The job is slow enough to be a problem, but not slow enough to fail outright, so it's easy to live with for a long time.

**Example (from the source)**
The team notices the cleanup job is slow, so they add an index on `created`. The job still takes about 25 s on their production table, and `EXPLAIN` shows the index isn't used. The post then reports that adding a lower bound to the date range cut the job to 0.5 s, but doesn't convincingly explain why. In this lesson you'll find out what is really going on.

**When it happens**
It gets worse over time. The `node` table grows every day, because every event creates a node. The cleanup job runs every night, but it also has to find and remove old finished rows from a table that has been growing for years. Nothing changes in the code, yet the job keeps getting slower. It shows up as:
- a nightly job that starts to overlap with the next day's traffic
- longer locks and more load on the database during the night
- a team that stops trusting the cleanup and starts doing it by hand

**The table: `node`**
One row is one unit of work or event the system tracked, such as a task or a message. It's created once, and it's marked finished when the work is done.

| column | what it means |
|---|---|
| `id` | a number that identifies this row |
| `created` | when the row was created (date and time) |
| `finished` | when the work was finished. **Empty means still open.** |

Real rows (from our test run on 2026-11-24, times in +05:30):

| id | created | finished |
|---|---|---|
| 1 | 2023-11-25 19:18 | 2023-11-26 00:55 |
| 2 | 2023-11-25 19:20 | 2023-11-25 20:37 |
| 39 | 2023-11-25 20:57 | *(empty: still open)* |
| 600000 | 2026-11-24 19:15 | 2026-11-24 19:18 |

The table has 600,000 rows over 3 years. 594,097 (99%) are finished, and 5,903 never finished. 396,017 of them are finished *and* older than a year, so those are what the nightly job should delete. "Older than a year" is measured from the moment the job runs, so the numbers shift a little each day.

The real table in the source was bigger, and the post doesn't say how big. We scaled it down so it loads in seconds on a laptop. The problem still shows.

**What the app does (naive.sql)**
Every night, the job deletes every row where `finished` is set and `created` is more than 365 days ago. It runs unchanged.

**Words used here**
- **Node:** a row in this table. It's just a name for the thing being tracked.
- **Index on `created`:** a sorted copy of the `created` column. It helps Postgres find rows by date without reading the whole table, like the index at the back of a book.

**Context: the data**
- rows are created in time order, the way an append-only log would be
- autovacuum is off for this table so results are repeatable (see `data.sql`)

**Source**
[Dataminded: When SQL isn't enough: debugging PostgreSQL in production](https://medium.com/datamindedbe/when-sql-isnt-enough-debugging-postgresql-in-production-fbca5dff7467). The post blames the unbounded time range for skipping the index. Decide for yourself whether that's the real cause; the check doesn't care about the explanation, only the result.

**Run**
Write your fix in `solution.sql`, then run `./check.sh`. It reloads the data, applies your fix, times the job, then runs it and checks what's left.

**Rules**
`naive.sql` is the job. Don't change it. You can change the database. Anything autovacuum would normally do for this table, you do by hand.

**Baseline** (empty `solution.sql`)
The job takes about 0.4 to 0.7 s on our laptop. `EXPLAIN ANALYZE` shows a sequential scan over the whole table. At the post's scale the same job would take far longer.

**The check wants**
- the job runs in under 100 ms
- no finished node older than a year is left
- nodes newer than a year are untouched

**Hints** (open one at a time)

Hint 1

Run `EXPLAIN (ANALYZE, BUFFERS)` on the job. How many rows does it delete, compared with the table size? Is the plan wrong for that?


Hint 2

The job is meant to run every night. How many rows should it delete on a normal night? What would the table have to look like for that to be true?


Hint 3

After you remove a lot of rows, what does the table still carry around, and what does the planner still believe about it?

