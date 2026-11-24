# 07 No overlapping bookings

**Concept:** time ranges, and rules that compare a row with the other rows (not just check one row on its own). Also why checking in app code fails when requests arrive at the same moment.
Before you start: lesson 04 (constraints).

## The setting
Trimly's London salon has 6 stylists. Customers book one-hour appointments through three apps: the website, the mobile app, and the reception tablet. All three run the same booking code against one Postgres database.

## The data
**`staff`**: one row per stylist. Asha, Ben, Chen, Dara, Eli and Farah (ids 1 to 6).

**`bookings`**: one row per appointment in a stylist's diary.

| column | what it means |
|---|---|
| `id` | the booking's number |
| `staff_id` | which stylist |
| `customer_email` | who booked |
| `starts_at`, `ends_at` | when the appointment starts and ends (UTC) |
| `status` | `confirmed` (the slot is taken) or `cancelled` (the slot is free again) |

Ben's diary on 2 June 2027 (real rows; 12:00 is free):

| id | stylist | customer_email | starts_at | ends_at | status |
|---|---|---|---|---|---|
| 26 | Ben | customer265@example.com | 09:00 | 10:00 | confirmed |
| 31 | Ben | customer42@example.com | 10:30 | 11:30 | confirmed |
| 40 | Ben | customer194@example.com | 14:00 | 15:00 | confirmed |
| 43 | Ben | customer58@example.com | 15:30 | 16:30 | confirmed |
| 48 | Ben | customer288@example.com | 17:00 | 18:00 | confirmed |

A cancelled one, from the day before: booking 5, Ben, 1 June 10:30 to 11:30, `cancelled`. That slot is free again.

In total there are 300 bookings from 1 to 12 June, and 38 are cancelled. An appointment that ends at 11:00 and one that starts at 11:00 don't clash.

## The current code (`naive.sql`)
For one booking request:
1. **Is the slot free?** Look for a confirmed booking for this stylist that overlaps the requested time.
2. **Take the deposit.** The app calls the payment provider, which takes about 300 ms. In the file, `pg_sleep(0.3)` stands for that call.
3. **Save the booking**, if step 1 said the slot was free.

## What goes wrong
Ben's 10:00 on 15 June opens up. A promotion goes out, and two customers tap "Book" at nearly the same moment:

| time | Customer A | Customer B | Ben's 10:00 in the database |
|---|---|---|---|
| 0 ms | step 1: free | | empty |
| 5 ms | | step 1: free | empty |
| 300 ms | step 3: saves | | A |
| 305 ms | | step 3: saves | A **and** B |

Both get a confirmation email. On the day, both turn up for the same chair. Each request did the right thing on its own, but step 1 and step 3 are separate, and the other request slipped in between. With 50 requests at once, you get 50 confirmed bookings for one slot.

It's easy to miss because in testing, one person books at a time, and the gap never matters. It only shows up under real traffic.

## Your task
Make it impossible for the database to hold two confirmed bookings for the same stylist at overlapping times, whichever app writes them and however many write at once. Back-to-back bookings, and booking a slot after a cancellation, must still work.

Leave `naive.sql` as it is. Three apps share that code, and the rule has to hold even for code you don't control.

## Done when
- 50 requests at once for Ben's 10:00 on 15 June leave exactly 1 confirmed booking
- Ben 10:30 to 11:30 on the same day is refused, because it overlaps 10:00 to 11:00
- Ben 11:00 to 12:00 is accepted (back-to-back), and so is Asha at 10:00 (a different stylist)
- after the 10:00 booking is cancelled, Ben's 10:00 can be booked again

## Run
```
./check.sh    # creates learn_07, loads the data, runs your solution.sql, sends 50 requests at once, checks the edge cases
psql learn_07 # look around
psql learn_07 -v staff=2 -v slot_start='2027-06-15 10:00+00' -v slot_end='2027-06-15 11:00+00' -v email=ravi@example.com -f naive.sql   # one booking request
```

## Words used
- **Overlap:** two time ranges share at least one moment. 10:00 to 11:00 overlaps 10:30 to 11:30, but not 11:00 to 12:00.
- **Concurrent requests:** requests handled at the same time.
- **Race condition:** a bug where the result depends on which request gets there first.
- **Range:** a single value that holds a start and an end, like "10:00 to 11:00".

## Hints

Hint 1

The check in step 1 and the insert in step 3 are separate steps. Where could "is it free?" and "save it" happen as one step, for every app?


Hint 2

A `UNIQUE` constraint compares a new value with every other row using "equals". Here you need to compare a time range with every other row for the same stylist using "overlaps".


Hint 3

Look up range types (`tstzrange`) and exclusion constraints (`EXCLUDE USING gist`). To mix "equals" on `staff_id` with "overlaps" on the range, you need the `btree_gist` extension.

