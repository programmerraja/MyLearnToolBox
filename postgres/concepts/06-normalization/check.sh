#!/usr/bin/env bash
# Reloads the wide table, runs your solution.sql, then checks the new tables.
cd "$(dirname "$0")" && export PGDATABASE=learn_06 && . ../../infra/lib.sh

psql -q -f data.sql >/dev/null
psql -q -v ON_ERROR_STOP=1 -f solution.sql || fail "solution.sql stopped with an error"
q() { psql -Atc "$1" 2>/dev/null; }

got=$(q "select (select count(*) from customers) || ',' || (select count(*) from staff) || ',' || (select count(*) from services) || ',' || (select count(*) from bookings)")
[ "$got" = "3,2,3,8" ] && pass "3 customers, 2 staff, 3 services, 8 bookings" || fail "counts (customers,staff,services,bookings) are '${got}' (want 3,2,3,8)"

got=$(q "select email from customers where name = 'Ravi Kumar'")
[ "$got" = "ravi.k@example.com" ] && pass "Ravi has one email, the current one" || fail "Ravi's email is '${got}' (want ravi.k@example.com)"

got=$(q "select string_agg(name || '=' || price::numeric(8,2), ', ' order by name) from services")
[ "$got" = "Beard trim=12.50, Colour=65.00, Haircut=28.00" ] && pass "price list shows today's prices" || fail "price list is '${got}' (want Beard trim=12.50, Colour=65.00, Haircut=28.00)"

got=$(q "select count(*) from bookings b
         join customers c on c.id = b.customer_id
         join staff s     on s.id = b.staff_id
         join services v  on v.id = b.service_id
         join booking_lines l on l.booking_id = b.id
         where c.name = l.customer_name and s.name = l.staff_name and v.name = l.service_name
           and b.price = l.service_price and b.starts_at = l.starts_at")
[ "$got" = 8 ] && pass "every booking has the right customer, stylist, service and the price paid" || fail "${got:-0} of 8 bookings match the original rows"

got=$(q "select count(*) from information_schema.columns where table_name = 'bookings' and column_name in ('customer_name', 'customer_email', 'staff_name', 'service_name')")
[ "$got" = 0 ] && pass "bookings doesn't repeat customer, stylist or service details" || fail "bookings still has $got copied detail column(s)"

got=$(psql -qAt -c "BEGIN" -c "UPDATE services SET price = 30 WHERE name = 'Haircut'" -c "SELECT sum(price) FROM bookings" -c "ROLLBACK" 2>/dev/null)
[ "$got" = "253.00" ] && pass "raising a price doesn't change what past bookings cost" || fail "after raising the haircut price, bookings total is '${got}' (want 253.00)"

exit $FAILED
