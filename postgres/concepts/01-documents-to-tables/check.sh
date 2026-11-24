#!/usr/bin/env bash
# Reloads the raw documents, runs your solution.sql, then checks the new tables and the report.
cd "$(dirname "$0")" && export PGDATABASE=learn_01 && . ../../infra/lib.sh

psql -q -f data.sql >/dev/null
psql -q -v ON_ERROR_STOP=1 -f solution.sql || fail "solution.sql stopped with an error"
q() { psql -Atc "$1" 2>/dev/null; }

got=$(q "select count(*) from customers")
[ "$got" = 4 ] && pass "4 customers, one per person" || fail "customers has ${got:-no} rows (want 4, one per person)"

got=$(q "select string_agg(name, ', ' order by name) from staff")
[ "$got" = "Asha, Ben" ] && pass "staff is Asha, Ben" || fail "staff names are '${got}' (want 'Asha, Ben')"

got=$(q "select string_agg(id::text, ',' order by id) from bookings")
[ "$got" = "1,2,3,4,5,6,7,8" ] && pass "all 8 bookings moved, same ids" || fail "booking ids are '${got}' (want 1 to 8)"

got=$(q "select string_agg(column_name || ':' || data_type, ', ' order by column_name) from information_schema.columns where table_name = 'bookings' and column_name in ('price', 'starts_at')")
[ "$got" = "price:numeric, starts_at:timestamp with time zone" ] && pass "price is numeric, starts_at is timestamptz" || fail "column types are '${got}' (want price numeric, starts_at timestamp with time zone)"

got=$(q "select count(*) from bookings b join customers c on c.id = b.customer_id join bookings_raw r on r.id = b.id where c.email = coalesce(r.doc->'customer'->>'email', r.doc->>'customer_email')")
[ "$got" = 8 ] && pass "every booking points at the right customer" || fail "${got:-0} of 8 bookings point at the right customer"

got=$(q "select string_agg(name || '=' || total, ', ' order by name) from (select s.name, sum(b.price)::numeric(10,2) as total from bookings b join staff s on s.id = b.staff_id group by s.name) t")
[ "$got" = "Asha=147.50, Ben=110.00" ] && pass "report: Asha 147.50, Ben 110.00" || fail "report gives '${got}' (want Asha=147.50, Ben=110.00)"

exit $FAILED
