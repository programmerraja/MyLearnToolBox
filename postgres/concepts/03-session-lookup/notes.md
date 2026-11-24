# 03 Session lookup

**Problem**
Every request to the app checks the user's session: it looks up the session by its token and confirms it's active. On a table with 2 million sessions, that lookup scans the whole table. Under load, the connection pool runs out, requests time out, and checkout breaks.

**Example (from the source)**
At 3 AM the alerts start. Customers can't check out: pages spin for 30 to 60 seconds, then time out. All 200 database connections are busy, with dozens more requests waiting. The cause turns out to be two simple queries on the sessions table, including the session check. Together they account for 99% of the database's time.

**When it happens**
- on every request, so it hits hardest at peak traffic (evenings, sales)
- as the sessions table grows. Each login adds a row, and old sessions aren't removed quickly
- when the table is large enough that a full scan takes longer than the connection timeout

It's easy to miss early on. When the table has a few thousand rows, a full scan is instant, so no one notices. The slowdown arrives gradually, and then all at once when traffic spikes.

**The table: `user_sessions`**
One row is one login session: one user, signed in on one device, for a limited time.

| column | what it means |
|---|---|
| `id` | a number that identifies this row |
| `user_id` | which user the session belongs to |
| `session_token` | a long random string the browser sends with every request, to prove who it is. Here it's 32 characters. |
| `is_active` | `true` while the session is valid, `false` once it's logged out or expired |

Real rows (from our test run):

| id | user_id | session_token | is_active |
|---|---|---|---|
| 1 | 371472 | c4ca4238a0b923820dcc509a6f75849b | true |
| 2 | 468302 | c81e728d9d4c2f636f067f89cc14862c | true |
| 1683 | 282551 | fddd7938a71db5f81fcc621673ab67b7 | true |

The table has 500,000 rows. About 60% are active (300,317). Every request in the app asks the same question: "Which active session has this token?"

The post's table had 2.1 million rows. We scaled it down so it loads in seconds on a laptop. The full scan is still clearly slow, and the problem is the same.

**Words used here**
- **Token:** the secret string that identifies a session. Two sessions never share a token.
- **Connection pool:** a fixed set of database connections the app shares. If every connection is busy waiting, new requests wait too, then time out.

**What the app does (naive.sql)**
On every request, the app runs this query, unchanged:
```
SELECT count(*) FROM user_sessions WHERE is_active AND session_token = '<token>';
```
In plain words: count the rows where the token matches and the session is still active. The answer is 1 for a valid session and 0 for an invalid one.

**Source**
[Issath: 929 Billion Rows Scanned: How We Killed Our Database Performance](https://buildsmartengineering.substack.com/p/929-billion-rows-scanned-how-we-killed) (Oct 2025). The post measured 52.8 s per query on production under load, with 15 queries running at once. You'll measure one query on your laptop, so compare ratios, not absolute times.

**Run**
Write your fix in `solution.sql`, then run `./check.sh`. It reloads the data, applies your fix, and times the lookup.

**Rules**
`naive.sql` is the app's query. Don't change it. You can change the database.

**Baseline** (empty `solution.sql`)
About 15 ms per lookup on our laptop (the post saw 52.8 s on a bigger table under load). `EXPLAIN ANALYZE` shows a Parallel Seq Scan over the whole table.

**The check wants**
- the lookup runs in under 2 ms

**Hints** (open one at a time)

Hint 1

Run `EXPLAIN (ANALYZE, BUFFERS)` on the query. What does Postgres read to find a single row?


Hint 2

Which columns does the query filter on, and which of them narrows the result down to one row?


Hint 3

The order of columns in a multi-column index matters. Can the whole answer come from the index without touching the table?

