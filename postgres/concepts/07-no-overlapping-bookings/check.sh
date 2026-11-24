#!/usr/bin/env bash
# Reloads the diary, runs your solution.sql, sends 50 booking requests for one slot at the same moment, then tries edge cases.
cd "$(dirname "$0")" && export PGDATABASE=learn_07 && . ../../infra/lib.sh

psql -q -f data.sql >/dev/null
psql -q -v ON_ERROR_STOP=1 -f solution.sql || fail "solution.sql stopped with an error"
q() { psql -Atc "$1" 2>/dev/null; }

for i in $(seq 50); do
  psql -q -v staff=2 -v slot_start='2027-06-15 10:00+00' -v slot_end='2027-06-15 11:00+00' -v email="customer$i@example.com" -f naive.sql >/dev/null 2>&1 &
done
wait

got=$(q "select count(*) from bookings where staff_id = 2 and starts_at = '2027-06-15 10:00+00' and status = 'confirmed'")
[ "$got" = 1 ] && pass "50 requests at once for Ben's 10:00 -> 1 booking" || fail "50 requests at once for Ben's 10:00 -> $got bookings (want 1)"

try() {  # expect (accept|refuse), description, SQL
  if psql -q -c "$3" >/dev/null 2>&1; then [ "$1" = accept ] && pass "accepted: $2" || fail "accepted: $2"
  else [ "$1" = refuse ] && pass "refused: $2" || fail "refused: $2"; fi
}
try refuse "Ben 10:30-11:30, overlaps his 10:00-11:00" "INSERT INTO bookings (staff_id, customer_email, starts_at, ends_at) VALUES (2, 'x@example.com', '2027-06-15 10:30+00', '2027-06-15 11:30+00')"
try accept "Ben 11:00-12:00, starts when 10:00-11:00 ends" "INSERT INTO bookings (staff_id, customer_email, starts_at, ends_at) VALUES (2, 'y@example.com', '2027-06-15 11:00+00', '2027-06-15 12:00+00')"
try accept "Asha 10:00-11:00, a different stylist"         "INSERT INTO bookings (staff_id, customer_email, starts_at, ends_at) VALUES (1, 'z@example.com', '2027-06-15 10:00+00', '2027-06-15 11:00+00')"
psql -q -c "UPDATE bookings SET status = 'cancelled' WHERE staff_id = 2 AND starts_at = '2027-06-15 10:00+00'" >/dev/null 2>&1
try accept "Ben 10:00-11:00 again, after it was cancelled" "INSERT INTO bookings (staff_id, customer_email, starts_at, ends_at) VALUES (2, 'w@example.com', '2027-06-15 10:00+00', '2027-06-15 11:00+00')"

exit $FAILED
