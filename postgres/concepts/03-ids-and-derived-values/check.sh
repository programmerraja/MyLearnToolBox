#!/usr/bin/env bash
# Reloads both salons' tables, runs your solution.sql, then checks the merged bookings table.
cd "$(dirname "$0")" && export PGDATABASE=learn_03 && . ../../infra/lib.sh

psql -q -f data.sql >/dev/null
psql -q -v ON_ERROR_STOP=1 -f solution.sql || fail "solution.sql stopped with an error"
q() { psql -qAtc "$1" 2>/dev/null; }

got=$(q "select string_agg(branch || old_id, ',' order by branch, old_id) from bookings")
[ "$got" = "DXB1,DXB2,DXB3,DXB4,LDN1,LDN2,LDN3,LDN4" ] && pass "all 8 bookings moved, each with its salon and old id" || fail "branch + old_id are '${got}' (want DXB1..DXB4 and LDN1..LDN4)"

got=$(q "select data_type from information_schema.columns where table_name = 'bookings' and column_name = 'id'")
[ "$got" = uuid ] && pass "id is a uuid" || fail "id is '${got}' (want an id that can't clash between salons or devices)"

got=$(q "select string_agg(branch || '=' || revenue, ', ' order by branch) from (select branch, sum(total) as revenue from bookings group by branch) t")
[ "$got" = "DXB=455.50, LDN=133.00" ] && pass "revenue: DXB 455.50, LDN 133.00" || fail "revenue is '${got}' (want DXB=455.50, LDN=133.00)"

got=$(q "insert into bookings (branch, customer_email, price, tip) values ('LDN', 'new@example.com', 25, 2) returning total")
[ "$got" = "27.00" ] && pass "a new booking gets an id by itself, and total = price + tip" || fail "new booking without id or total gave total '${got}' (want 27.00)"

psql -q -c "insert into bookings (id, branch, customer_email, price, tip) values ('6f1c2a7e-3b4d-4e5f-9a0b-1c2d3e4f5a6b', 'DXB', 'tablet@example.com', 50, 5)" >/dev/null 2>&1 \
  && pass "a booking made offline on a tablet, with its own id, is accepted" || fail "a booking with an id made on a tablet was refused"

psql -q -c "insert into bookings (branch, customer_email, price, tip, total) values ('LDN', 'typo@example.com', 25, 2, 999)" >/dev/null 2>&1
psql -q -c "update bookings set total = 1 where customer_email = 'omar@example.com'" >/dev/null 2>&1
got=$(q "select count(*) from bookings where total is distinct from price + tip")
[ "$got" = 0 ] && pass "a wrong total can't be stored (insert or update)" || fail "${got:-some} booking(s) have a total that isn't price + tip"

exit $FAILED
