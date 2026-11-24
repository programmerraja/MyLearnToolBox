# 01 From documents to tables

**Concept:** schema-first vs schemaless. In MongoDB every document can have its own shape, and the app copes. In Postgres you decide the shape up front (tables, columns, types), and the database holds every row to it. This lesson is that switch: design tables and move messy documents into them.
Before you start: basic SQL (`CREATE TABLE`, `INSERT ... SELECT`, `JOIN`).

## The setting
Trimly runs hair salons. Customers book appointments with a stylist through Trimly's website and mobile app. For six years the bookings lived in MongoDB. Trimly is moving to Postgres, and the first step copied each booking document, as-is, into one table.

## The data: `bookings_raw`
One row is one booking, exactly as MongoDB stored it.

| column | what it means |
|---|---|
| `id` | the booking's number |
| `doc` | the whole booking document, as JSON (`jsonb`) |

Two of the real documents:
```json
{"customer": {"name": "Ravi Kumar", "email": "ravi@example.com"}, "staff": "Asha", "service": "Haircut", "price": 25.00, "starts_at": "2026-03-02T10:00:00Z"}
{"customer_name": "Lena Park", "customer_email": "lena@example.com", "stylist": "asha", "service": "Haircut", "price": 25, "starts_at": "2026-03-05T12:00:00Z"}
```

All 8 bookings, with each document's fields laid out as columns:

| id | customer is stored as | stylist is stored as | service | price stored as | starts at (UTC) |
|---|---|---|---|---|---|
| 1 | `customer: {name, email}`: Ravi Kumar | `staff: "Asha"` | Haircut | `25.00` | 2026-03-02 10:00 |
| 2 | `customer: {...}`: Meera Iyer | `staff: "Asha"` | Colour | `"60.00"` (text) | 2026-03-02 11:00 |
| 3 | `customer_name`, `customer_email`: Tom Hughes | `staff: "Ben"` | Haircut | `25` | 2026-03-02 10:00 |
| 4 | `customer: {...}`: Ravi Kumar | `staff: "asha "` | Beard trim | `12.5` | 2026-03-03 09:30 |
| 5 | `customer: {...}`: Lena Park | `stylist: "Ben"` | Colour | `60` | 2026-03-03 14:00 |
| 6 | `customer: {...}`: Meera Iyer | `staff: "Ben"` | Haircut | `25` | 2026-03-04 16:00 |
| 7 | `customer: {...}`: Tom Hughes | `staff: "Asha"` | Haircut | `"25"` (text) | 2026-03-05 10:00 |
| 8 | `customer_name`, `customer_email`: Lena Park | `stylist: "asha"` | Haircut | `25` | 2026-03-05 12:00 |

Why it's messy: the apps changed over six years. The first mobile app sent flat customer fields. A later version renamed `staff` to `stylist`. The old web form sent prices as text. Receptionists typed stylist names by hand. MongoDB accepted all of it.

There are 4 real customers (Ravi, Meera, Tom, Lena) and 2 stylists (Asha, Ben). An email identifies a customer.

## The current code (`naive.sql`)
The weekly "revenue per stylist" report reads the documents directly: take the `staff` field, add up the prices, group by stylist.

## What goes wrong
Run it and you get:

| stylist | revenue |
|---|---|
| Asha | 110.00 |
| asha | 12.5 |
| Ben | 50 |
| *(empty)* | 85 |

The real answer is **Asha 147.50, Ben 110.00**. Asha appears twice because one booking says `"asha "`, lowercase with a trailing space. Two bookings fall into the empty row because they use `stylist`, not `staff`. Stylists' bonuses come from this report, so this week Asha is underpaid by 37.50.

Nothing in the query looks wrong: it's correct for the shape it expects. That's the trap with schemaless data. Every report has to remember every old shape, forever, and the first one that forgets is silently wrong.

## Your task
Move the data into proper tables, so the shape is decided once and every report can trust it. The reporting team will query these tables, so use these names:
- `customers (id, name, email)`: one row per person
- `staff (id, name)`: one row per stylist, names written properly (`Asha`, `Ben`)
- `bookings (id, customer_id, staff_id, service, price, starts_at)`: the same ids as `bookings_raw`. `price` is an exact number, `starts_at` a timestamp with time zone.

## Done when
- 4 customers, 2 staff (Asha, Ben), 8 bookings with ids 1 to 8
- `price` is `numeric` and `starts_at` is `timestamp with time zone`
- every booking points at the right customer
- revenue per stylist from your tables is Asha 147.50, Ben 110.00

## Run
```
./check.sh                   # creates learn_01, loads the data, runs your solution.sql, checks it
psql learn_01 -f naive.sql   # the current report
psql learn_01                # look around, e.g. SELECT id, doc FROM bookings_raw;
```

## Words used
- **Schemaless:** the database doesn't enforce a shape; each document can differ.
- **Schema-first:** you define tables and columns first; every row must fit them.
- **jsonb:** Postgres's JSON column type. `doc->'customer'` gets the nested object, `doc->>'staff'` gets a field as text.

## Hints

Hint 1

Before writing any SQL, list every variation you can see: where the customer lives, which key holds the stylist, how prices and names are written.


Hint 2

`coalesce(a, b)` returns the first value that isn't null, which helps when the same thing lives under two keys. `trim()` and `initcap()` clean up names.


Hint 3

Fill the tables in order: `staff` and `customers` first, then `bookings`, joining back to them to get their ids (`INSERT INTO ... SELECT ... JOIN`).

