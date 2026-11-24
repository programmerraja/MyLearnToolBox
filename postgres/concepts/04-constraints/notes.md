# 04 Constraints keep bad data out

**Concept:** constraints: `NOT NULL`, `CHECK`, `UNIQUE` (including case-insensitive uniqueness), and `FOREIGN KEY`. These are rules the database enforces on every write, from every app.
Before you start: lessons 01 and 02.

## The setting
During the move, Trimly's `customers` and `bookings` tables were created in a hurry, with no rules. Three apps write to them: the website, the mobile app, and the reception tablet. Each app checks input in its own code, a little differently. Last week a buggy import ran too.

## The data
**`customers`**: one row per customer account.

| id | name | email | |
|---|---|---|---|
| 1 | Ravi Kumar | ravi@example.com | |
| 2 | Meera Iyer | meera@example.com | |
| 3 | Tom Hughes | tom@example.com | |
| 4 | Lena Park | lena@example.com | |
| 5 | Ravi Kumar | RAVI@example.com | same person, signed up again from the mobile app |

**`bookings`**: one row per appointment. `status` is `confirmed` (booked), `cancelled`, or `completed` (done and paid).

| id | customer_id | starts_at | price | status | |
|---|---|---|---|---|---|
| 1 | 1 | 2026-03-02 10:00 | 25.00 | confirmed | |
| 2 | 2 | 2026-03-02 11:00 | 60.00 | confirmed | |
| 3 | 3 | 2026-03-02 10:00 | 25.00 | cancelled | |
| 4 | 5 | 2026-03-03 09:30 | 12.50 | confirmed | Ravi's second account |
| 5 | 4 | 2026-03-03 14:00 | 60.00 | completed | |
| 6 | 99 | 2026-03-04 16:00 | 25.00 | confirmed | customer 99 doesn't exist |
| 7 | 2 | *(empty)* | 25.00 | confirmed | no start time |
| 8 | 3 | 2026-03-05 10:00 | -25.00 | confirmed | negative price |
| 9 | 4 | 2026-03-05 12:00 | 25.00 | Confrimed | typo |

## The current code (`naive.sql`)
1. Three inserts, the kind the apps send today. All three are accepted: a booking for customer 999, a booking with price -5, and Meera signing up again as `Meera@Example.com`.
2. The weekly revenue per customer report: add up the prices of bookings that aren't cancelled, per customer name.

## What goes wrong
The report after those inserts:

| name | revenue |
|---|---|
| Lena Park | 85.00 |
| Meera Iyer | 85.00 |
| Ravi Kumar | 32.50 |
| Tom Hughes | -25.00 |

- **Tom owes money?** His only active booking has a price of -25.
- **Did Meera's 25 happen?** Booking 7 has no start time, so nobody knows when.
- **Lena's 85 counts the `Confrimed` typo** because the report only excludes `cancelled`. A report that asks for `status = 'confirmed'` would miss it.
- **Bookings 6 and 20 are missing.** Their customers don't exist, so the join drops them. That's 50 of revenue nobody can attribute.
- **Ravi has two accounts**, and Meera now has two as well. Their history and loyalty points are split.

It's easy to miss because each app validates in its own code. One app forgets one check, bad data gets in, and someone finds it weeks later in a report.

## Your task
1. **Clean the existing data** by the rules finance agreed:
   - delete bookings whose customer doesn't exist, or with no start time, or with a negative price (they came from the buggy import)
   - fix the typo: `Confrimed` is `confirmed`
   - Ravi's two accounts are one person: keep id 1, move his bookings to it, delete id 5
2. **Make the database refuse bad rows from now on**, whichever app sends them:
   - every booking has a real customer, a start time, a price of 0 or more, and a status of `confirmed`, `cancelled` or `completed`
   - every customer has a name and an email, and no two customers share an email, ignoring upper and lower case

## Done when
- bookings 1, 2, 3, 4, 5 and 9 remain; customers 1 to 4 remain; booking 4 belongs to customer 1; booking 9 says `confirmed`
- the database refuses: a booking for a missing customer, with no customer, with no start time, with a negative price, or with an unknown status; a customer with no email; a second account for `MEERA@example.com`
- the database still accepts a new customer, and a booking with price 0

## Run
```
./check.sh                   # creates learn_04, loads the data, runs your solution.sql, checks it
psql learn_04 -f naive.sql   # the inserts the apps send today, and the report
psql learn_04                # look around
```

## Words used
- **Constraint:** a rule attached to a table. Postgres checks it on every insert and update, and refuses the write if it's broken.
- **Foreign key:** a column whose value must exist in another table (`bookings.customer_id` must be a real `customers.id`).
- **Case-insensitive:** treating `A` and `a` as the same.

## Hints

Hint 1

Clean first, then add the rules. When you add a constraint, Postgres checks the existing rows and refuses if any of them break it.


Hint 2

Each business rule maps to one kind of constraint. Go through the list in "Your task" and name the kind for each one.


Hint 3

A plain `UNIQUE` on `email` treats `meera@` and `MEERA@` as different values. Look up unique indexes on expressions, such as `lower(email)`.

