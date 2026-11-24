# 06 Normalization

**Concept:** normalization. Store each fact in one place, so the data can't disagree with itself. And know when a copy is correct on purpose, like the price a customer paid on the day.
Before you start: lessons 01 and 04.

## The setting
Trimly's finance team kept bookings in a spreadsheet, and it was imported into Postgres as one wide table. Now marketing uses it to email customers their booking summary, and the website reads its price list from it.

## The data: `booking_lines`
One row is one booking, with the customer, stylist and service details copied into every row.

| column | what it means |
|---|---|
| `booking_id` | the booking's number |
| `customer_name`, `customer_email` | who booked |
| `staff_name` | the stylist |
| `service_name`, `service_price` | what was booked, and the price on that day |
| `starts_at` | when the appointment was (UTC) |

All 8 rows:

| booking_id | customer_name | customer_email | staff_name | service_name | service_price | starts_at |
|---|---|---|---|---|---|---|
| 1 | Ravi Kumar | ravi@example.com | Asha | Haircut | 25.00 | 2026-01-10 10:00 |
| 2 | Meera Iyer | meera@example.com | Asha | Colour | 60.00 | 2026-01-10 11:00 |
| 3 | Ravi Kumar | ravi@example.com | Ben | Beard trim | 12.50 | 2026-01-17 09:30 |
| 4 | Tom Hughes | tom@example.com | Ben | Haircut | 25.00 | 2026-01-24 10:00 |
| 5 | Meera Iyer | meera@example.com | Ben | Haircut | 25.00 | 2026-02-07 16:00 |
| 6 | Ravi Kumar | ravi.k@example.com | Asha | Haircut | 28.00 | 2026-03-02 10:00 |
| 7 | Tom Hughes | tom@example.com | Asha | Colour | 65.00 | 2026-03-05 12:00 |
| 8 | Ravi Kumar | ravi@example.com | Ben | Beard trim | 12.50 | 2026-03-09 09:30 |

What the business knows:
- Ravi changed his email to **ravi.k@example.com** in February. Booking 8 was entered by copying an old row, so it has his old address.
- In March, a haircut went up from 25 to 28 and colour from 60 to 65. Beard trim stayed at 12.50.
- In this data, no two customers share a name.

## The current code (`naive.sql`)
1. **Booking summaries:** one row per customer, with their email and number of bookings.
2. **Website price list:** each service and its price.

## What goes wrong
Booking summaries:

| customer_name | customer_email | bookings |
|---|---|---|
| Meera Iyer | meera@example.com | 2 |
| Ravi Kumar | ravi.k@example.com | 1 |
| Ravi Kumar | ravi@example.com | 3 |
| Tom Hughes | tom@example.com | 2 |

Ravi appears twice. Most of his summary goes to an address he stopped using, and neither email shows his real total of 4.

Price list:

| service_name | service_price |
|---|---|
| Beard trim | 12.50 |
| Colour | 60.00 |
| Colour | 65.00 |
| Haircut | 25.00 |
| Haircut | 28.00 |

The website can't tell which price is current.

The cause is the same in both. Each fact (Ravi's email, a service's price) is copied into many rows, so changing it means updating every one of them, and one missed row means the data disagrees with itself. But not every copy is wrong: Ravi paid 25 for his haircut on 10 January, and that must stay 25 after the price goes up.

## Your task
Split `booking_lines` into tables where each fact lives in one place, and keep what each booking actually cost. The app team expects these names:
- `customers (id, name, email)`: one row per customer, with their current email
- `staff (id, name)`
- `services (id, name, price)`: `price` is today's price
- `bookings (id, customer_id, staff_id, service_id, starts_at, price)`: the same ids as `booking_lines`; `price` is what was paid

## Done when
- 3 customers, 2 staff, 3 services, 8 bookings
- Ravi has one email: ravi.k@example.com
- the price list shows today's prices: Beard trim 12.50, Colour 65.00, Haircut 28.00
- every booking has the right customer, stylist, service, start time and the price paid
- `bookings` doesn't repeat the customer, stylist or service details
- raising a service's price doesn't change what past bookings cost

## Run
```
./check.sh                   # creates learn_06, loads the data, runs your solution.sql, checks it
psql learn_06 -f naive.sql   # the current queries
psql learn_06                # look around
```

## Words used
- **Normalization:** organising tables so each fact is stored once.
- **Update anomaly:** a fact stored in many rows gets changed in some of them, but not all.
- **Historical value:** a copy kept on purpose because it records what was true at the time (the price paid).

## Hints

Hint 1

For each column of `booking_lines`, ask: is this a fact about the booking, the customer, the stylist, or the service?


Hint 2

"Today's price" and "the price paid" are two different facts. Where does each one belong?


Hint 3

`SELECT DISTINCT ON (x) ... ORDER BY x, y DESC` picks one row per `x`, such as the latest. For Ravi's email, the latest row isn't the right answer, so use what the business told you.

