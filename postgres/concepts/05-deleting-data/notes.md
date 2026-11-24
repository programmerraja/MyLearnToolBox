# 05 Deleting data

**Concept:** what a foreign key does when the row it points to is deleted: refuse (the default), delete the related rows too (`ON DELETE CASCADE`), or keep them and clear the link (`ON DELETE SET NULL`). This is constraints again, from a second angle: lesson 04 kept bad rows out; this one is about rows going away.
Before you start: lesson 04 (constraints).

## The setting
Lena, a Trimly customer, has asked Trimly to delete her account. Privacy law says her personal data must go. Tax law says the bookings she paid for must stay in the accounts for six years. Support handles these requests with an admin tool that runs a single `DELETE` on the customer.

## The data
**`customers`**: Ravi (1), Meera (2), Tom (3), Lena (4), each with a name and email.
**`staff`**: Asha (1), Ben (2).

**`bookings`**: one row per appointment. `customer_id` and `staff_id` are foreign keys with the default rule.

| id | customer | stylist | starts_at | price |
|---|---|---|---|---|
| 1 | Ravi Kumar | Asha | 2026-03-02 10:00 | 25.00 |
| 2 | Meera Iyer | Asha | 2026-03-02 11:00 | 60.00 |
| 3 | **Lena Park** | Ben | 2026-03-03 14:00 | 60.00 |
| 4 | Tom Hughes | Ben | 2026-03-04 10:00 | 25.00 |
| 5 | **Lena Park** | Asha | 2026-03-05 12:00 | 25.00 |
| 6 | Ravi Kumar | Ben | 2026-03-09 09:30 | 12.50 |

March revenue: 207.50.

**`consents`**: one row per marketing channel a customer agreed to (`email`, `sms`), with when they agreed. Ravi: email. Meera: sms. **Lena: email and sms.** This is personal data.

## The current code (`naive.sql`)
Support's tool runs one statement: `DELETE FROM customers WHERE id = 4;`

## What goes wrong
It's refused:
```
ERROR:  update or delete on table "customers" violates foreign key constraint "bookings_customer_id_fkey" on table "bookings"
DETAIL:  Key (id)=(4) is still referenced from table "bookings".
```
The default rule protects the bookings, but now support can't delete anyone who ever booked. The last time this happened, someone deleted Lena's consents, then her bookings, then her account, by hand. That left 4 bookings and **122.50** of revenue in March, against the 207.50 the bank had received. The accounts no longer matched, and finance spent a day finding out why.

It's easy to get wrong in both directions. Without a rule, deletes fail. With "delete everything related", one support click wipes financial records. The rule has to differ per table: personal data goes, financial records stay, and some deletes (a stylist with bookings) should still be refused.

## Your task
Change the database so that support's one `DELETE FROM customers WHERE id = 4` does the right thing:
- Lena's account is gone
- her consents are gone
- her bookings stay, for the accounts, but no longer point at her
- a stylist who has bookings still can't be deleted

Don't delete Lena in `solution.sql` yourself. The check runs support's `DELETE` after your fix.

## Done when
- support's `DELETE` works, and Lena's account is gone
- consents left: Ravi's email, Meera's sms
- all 6 bookings are kept (207.50); bookings 3 and 5 no longer point at a customer
- deleting Asha (who has bookings) is still refused

## Run
```
./check.sh                   # creates learn_05, loads the data, runs your solution.sql, then support's DELETE, checks it
psql learn_05 -f naive.sql   # support's DELETE, as it is today
psql learn_05                # look around: \d bookings shows the foreign keys
```

## Words used
- **Foreign key:** a column whose value must exist in another table.
- **Referential action:** what a foreign key does when the row it points to is deleted or changed (`NO ACTION`, `RESTRICT`, `CASCADE`, `SET NULL`, `SET DEFAULT`).
- **Personal data:** data about a person (name, email, consents) that privacy law lets them ask you to delete.

## Hints

Hint 1

Go table by table. When a customer is deleted, what should happen to their consents? To their bookings? And when a stylist is deleted, to their bookings?


Hint 2

A foreign key's delete rule is part of the constraint. To change it, drop the constraint and add it again with the rule you want. `\d bookings` shows the constraint's name.


Hint 3

Look up `ON DELETE CASCADE` and `ON DELETE SET NULL`. One of them can't work while `customer_id` is `NOT NULL`.

