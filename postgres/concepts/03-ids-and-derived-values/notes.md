# 03 Ids and derived values

**Concept:** two topics that show up together in one real merge:
- **ids that never clash:** a `serial` counter vs a `uuid`, and when each fits
- **derived values:** a column that is always computed from other columns (`GENERATED ... STORED`), so it can't drift

Before you start: lessons 01 and 02.

## The setting
Until now, Trimly's London and Dubai salons each had their own database. Trimly is merging them into one. Each salon's reception tablet also takes bookings while offline (the Wi-Fi in the Dubai salon drops a lot), and syncs them later.

## The data
Two tables with the same shape: **`london_bookings`** and **`dubai_bookings`**. One row is one booking.

| column | what it means |
|---|---|
| `id` | the booking's number in that salon's old database: a `serial`, counting 1, 2, 3... |
| `customer_email` | who booked |
| `price` | the service price |
| `tip` | the tip the customer added |
| `total` | what was charged. The till app typed it in. |

All 8 rows:

| salon | id | customer_email | price | tip | total |
|---|---|---|---|---|---|
| LDN | 1 | ravi@example.com | 25.00 | 3.00 | 28.00 |
| LDN | 2 | meera@example.com | 60.00 | 0.00 | 60.00 |
| LDN | 3 | tom@example.com | 25.00 | 5.00 | 30.00 |
| LDN | 4 | lena@example.com | 12.50 | 2.50 | 15.00 |
| DXB | 1 | omar@example.com | 150.00 | 20.00 | 170.00 |
| DXB | 2 | sara@example.com | 90.00 | 10.00 | **90.00** |
| DXB | 3 | omar@example.com | 75.50 | 0.00 | 75.50 |
| DXB | 4 | aisha@example.com | 99.90 | 10.10 | **100.00** |

Both salons counted from 1, so both have a booking 1, 2, 3 and 4. And the Dubai tablet app had a bug: two totals don't equal price + tip.

## The current code (`naive.sql`)
The merge script: create one `bookings` table with an integer `id`, copy London's bookings in, then copy Dubai's, then report revenue per salon from `total`.

## What goes wrong
The Dubai copy fails:
```
ERROR:  duplicate key value violates unique constraint "bookings_pkey"
DETAIL:  Key (id)=(1) already exists.
```
So the report only shows London (133.00), and Dubai's revenue is missing entirely.

Someone suggests adding 1000 to Dubai's ids. That works until London passes 1000 bookings, and it can't work for the tablets at all: a tablet that's offline can't ask the database for "the next number". Two tablets offline at once would hand out the same one.

The totals are a second, quieter problem. Even after the merge, Sara was charged 90.00 for 90 + 10, and Aisha 100.00 for 99.90 + 10.10. Dubai's real revenue is 455.50, but the stored totals add up to 435.50. Any app that types `total` itself can get it wrong again tomorrow.

## Your task
Create one `bookings` table for both salons, and move all 8 bookings into it:
- `id` can never clash, whichever salon or tablet creates the booking. A tablet must be able to make its own id while offline.
- keep where each booking came from: `branch` (`LDN` or `DXB`) and `old_id` (its number in the old database, empty for new bookings)
- `total` is always `price + tip`. Nobody can store a different total, by insert or by update.

The apps expect these columns: `bookings (id, branch, old_id, customer_email, price, tip, total)`.

## Done when
- all 8 bookings are there, each with its salon and old id
- `id` is a `uuid`
- revenue is DXB 455.50, LDN 133.00
- a new booking inserted without an `id` or `total` gets an id by itself, and its total is price + tip
- a booking with an id made on a tablet is accepted
- a wrong total can't be stored, by insert or by update

## Run
```
./check.sh                   # creates learn_03, loads the data, runs your solution.sql, checks it
psql learn_03 -f naive.sql   # the current merge script (it fails halfway)
psql learn_03                # look around
```

## Words used
- **`serial`:** an integer filled from a counter (a sequence) inside one database. Two databases count on their own, so they hand out the same numbers.
- **`uuid`:** a 128-bit id, written like `6f1c2a7e-3b4d-4e5f-9a0b-1c2d3e4f5a6b`. Random enough that anyone can make one without asking, and two will practically never match. `gen_random_uuid()` makes one. Postgres 18 also has `uuidv7()`, which puts the time first, so new ids sort in order.
- **Derived value:** a value computed from other values, like a total from a price and a tip.

## Hints

Hint 1

Two separate problems, two separate fixes. Which one is about who hands out the id, and which one is about who computes the total?


Hint 2

A column's `DEFAULT` is used when an insert doesn't give a value. What default would give every new booking an id without a shared counter?


Hint 3

Look up generated columns: `total numeric GENERATED ALWAYS AS (...) STORED`. When you copy the old bookings, don't copy their `total`.

