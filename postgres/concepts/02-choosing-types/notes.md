# 02 Choosing types

**Concept:** choosing column types. Money needs an exact type (`numeric`), not floating point. Times need to know their time zone (`timestamptz`), not just the wall clock (`timestamp`).
Before you start: lesson 01.

## The setting
Trimly now has two salons: London and Dubai. Each takes payments at the till. Every day, finance checks Trimly's totals against what the bank actually paid out. Head office watches a dashboard of payments per day, on one clock (UTC) so the two branches can be compared.

## The data
**`branches`**: one row per salon.

| code | city | tz (time zone) |
|---|---|---|
| LDN | London | Europe/London |
| DXB | Dubai | Asia/Dubai |

London's clocks go forward one hour on 29 March 2026: from UTC+0 to UTC+1. Dubai is always UTC+4.

**`payments`**: one payment at a till.

| column | what it means |
|---|---|
| `id` | payment number |
| `branch` | which salon (`LDN` or `DXB`) |
| `amount` | how much was paid. Stored as `double precision` (floating point). |
| `paid_at` | the time on the salon's wall clock. Stored as `timestamp` (no time zone). |

All 9 rows:

| id | branch | amount | paid_at (salon wall clock) |
|---|---|---|---|
| 1 | LDN | 24.90 | 2026-03-27 10:00 |
| 2 | LDN | 24.90 | 2026-03-27 11:30 |
| 3 | LDN | 24.90 | 2026-03-27 15:00 |
| 4 | LDN | 0.10 | 2026-03-27 15:05 |
| 5 | LDN | 0.20 | 2026-03-27 16:40 |
| 6 | DXB | 150.00 | 2026-03-27 19:00 |
| 7 | DXB | 75.50 | 2026-03-28 00:30 |
| 8 | LDN | 25.00 | 2026-03-30 09:00 |
| 9 | DXB | 99.90 | 2026-03-30 10:15 |

**`bank_settlements`**: what the bank paid out, per salon, per local day (exact amounts). For example, London on 27 March: 75.00.

## The current code (`naive.sql`)
1. **Reconciliation:** add up each salon's payments per day and list every day where the total differs from the bank's.
2. **Head office dashboard:** count payments per day.

## What goes wrong
**The reconciliation flags a mismatch that isn't real:**

| branch | day | our_total | bank_total |
|---|---|---|---|
| LDN | 2026-03-27 | 74.99999999999999 | 75.00 |

Every payment is right, but the sum is wrong. Floating point stores 24.90 and 0.10 as close binary approximations, and adding them leaves a tiny error. Finance spends time chasing it, and with thousands of payments a day, the real mismatches hide among the fake ones.

**The dashboard puts a payment on the wrong day:**

| utc_day | payments |
|---|---|
| 2026-03-27 | 6 |
| 2026-03-28 | 1 |
| 2026-03-30 | 2 |

Payment 7 was made in Dubai at 00:30 on the 28th, local time. That's 20:30 UTC on the 27th, so the 27th should show 7 payments and the 28th none. The column only stores the wall-clock time, so Postgres can't know which clock it was. London's payment 8 has the same problem: 09:00 on 30 March was 08:00 UTC, because the clocks had changed.

It's easy to miss because every value looks right when you `SELECT` it. Only sums, and comparisons across salons or across the clock change, break.

## Your task
Change the `payments` columns so that money is exact and `paid_at` holds the real moment each payment happened. The existing values are wall-clock times at their own salon, so convert each one using its salon's time zone. Keep the column names `amount` and `paid_at`, because the reports use them.

## Done when
- all 9 payments are still there
- `amount` is `numeric`, and London's 27 March total is exactly 75.00
- `paid_at` is `timestamp with time zone`
- payment 1 is 2026-03-27 10:00 UTC, payment 7 is 2026-03-27 20:30 UTC, payment 8 is 2026-03-30 08:00 UTC

## Run
```
./check.sh                   # creates learn_02, loads the data, runs your solution.sql, checks it
psql learn_02 -f naive.sql   # the current reports
psql learn_02                # look around
```
The lesson database shows times in UTC.

## Words used
- **Floating point** (`real`, `double precision`): fast, approximate numbers. Fine for measurements, wrong for money.
- **`numeric`:** exact decimal numbers. `numeric(10,2)` means up to 10 digits, 2 after the point.
- **`timestamp`:** a date and wall-clock time, with no idea where.
- **`timestamptz`:** a real moment in time. Postgres stores it in UTC and shows it in your session's time zone.
- **UTC:** the reference clock the world's time zones are measured from.

## Hints

Hint 1

In psql, try `SELECT 24.90::float8 + 24.90 + 24.90 + 0.10 + 0.20;` and then the same with `::numeric`. Then try `SELECT timestamp '2026-03-28 00:30' AT TIME ZONE 'Asia/Dubai';`.


Hint 2

Changing a column's type takes a `USING` clause that says how to convert each old value. Without one, which time zone does Postgres assume the old values were in?


Hint 3

`ALTER COLUMN ... TYPE ... USING ...` can't look things up in another table. If the conversion needs `branches.tz`, add a new column, fill it with `UPDATE ... FROM branches`, then swap it in.

