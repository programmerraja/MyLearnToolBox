#!/usr/bin/env bash
# Reloads the tables, runs your solution.sql, checks the cleanup, then tries good and bad inserts.
cd "$(dirname "$0")" && export PGDATABASE=learn_04 && . ../../infra/lib.sh

psql -q -f data.sql >/dev/null
psql -q -v ON_ERROR_STOP=1 -f solution.sql || fail "solution.sql stopped with an error"
q() { psql -Atc "$1" 2>/dev/null; }

# Cleanup
got=$(q "select string_agg(id::text, ',' order by id) from bookings")
[ "$got" = "1,2,3,4,5,9" ] && pass "bad bookings removed, good ones kept" || fail "booking ids are '${got}' (want 1,2,3,4,5,9)"
got=$(q "select string_agg(id::text, ',' order by id) from customers")
[ "$got" = "1,2,3,4" ] && pass "Ravi's duplicate account removed" || fail "customer ids are '${got}' (want 1,2,3,4)"
got=$(q "select customer_id from bookings where id = 4")
[ "$got" = 1 ] && pass "Ravi's booking 4 moved to his main account" || fail "booking 4 belongs to customer '${got}' (want 1)"
got=$(q "select status from bookings where id = 9")
[ "$got" = confirmed ] && pass "typo in booking 9 fixed" || fail "booking 9 status is '${got}' (want confirmed)"

# The database must refuse these
refuse() {  # description, SQL
  psql -q -c "$2" >/dev/null 2>&1 && fail "accepted: $1" || pass "refused: $1"
}
refuse "booking for a customer that doesn't exist" "INSERT INTO bookings VALUES (100, 999, '2026-04-01 10:00+00', 25, 'confirmed')"
refuse "booking with no customer"                  "INSERT INTO bookings VALUES (101, NULL, '2026-04-01 10:00+00', 25, 'confirmed')"
refuse "booking with no start time"                "INSERT INTO bookings VALUES (102, 1, NULL, 25, 'confirmed')"
refuse "booking with a negative price"             "INSERT INTO bookings VALUES (103, 1, '2026-04-01 10:00+00', -1, 'confirmed')"
refuse "booking with an unknown status"            "INSERT INTO bookings VALUES (104, 1, '2026-04-01 10:00+00', 25, 'Confrimed')"
refuse "customer with no email"                    "INSERT INTO customers VALUES (10, 'No Email', NULL)"
refuse "second account for meera, different case"  "INSERT INTO customers VALUES (11, 'Meera Iyer', 'MEERA@example.com')"

# ...and still accept these
accept() {
  psql -q -c "$2" >/dev/null 2>&1 && pass "accepted: $1" || fail "refused a valid row: $1"
}
accept "a new customer"            "INSERT INTO customers VALUES (12, 'Priya Shah', 'priya@example.com')"
accept "a free booking (price 0)"  "INSERT INTO bookings VALUES (105, 2, '2026-04-02 10:00+00', 0, 'completed')"

exit $FAILED
