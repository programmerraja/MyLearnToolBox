#!/usr/bin/env bash
# Reloads the tables, runs your solution.sql, then runs support's DELETE (naive.sql) and checks what's left.
cd "$(dirname "$0")" && export PGDATABASE=learn_05 && . ../../infra/lib.sh

psql -q -f data.sql >/dev/null
psql -q -v ON_ERROR_STOP=1 -f solution.sql || fail "solution.sql stopped with an error"
q() { psql -Atc "$1" 2>/dev/null; }

[ "$(q "select count(*) from customers where id = 4")" = 1 ] && pass "Lena is still there before support's delete" || fail "solution.sql removed Lena itself (leave that to support's delete)"

psql -q -v ON_ERROR_STOP=1 -f naive.sql >/dev/null 2>&1 && pass "support's one DELETE works" || fail "support's DELETE was refused: $(psql -q -f naive.sql 2>&1 | head -1)"

[ "$(q "select count(*) from customers where id = 4")" = 0 ] && pass "Lena's account is gone" || fail "Lena's account is still there"

got=$(q "select string_agg(customer_id || ':' || channel, ', ' order by customer_id, channel) from consents")
[ "$got" = "1:email, 2:sms" ] && pass "Lena's consents are gone, the others are kept" || fail "consents are '${got}' (want 1:email, 2:sms)"

got=$(q "select count(*) || ',' || sum(price) from bookings")
[ "$got" = "6,207.50" ] && pass "all 6 bookings kept for the accounts (207.50)" || fail "bookings (count,total) are '${got}' (want 6,207.50)"

got=$(q "select count(*) from bookings where id in (3, 5) and customer_id is null")
[ "$got" = 2 ] && pass "Lena's bookings no longer point at anyone" || fail "Lena's bookings 3 and 5 still point at a customer (or are gone)"

psql -q -c "DELETE FROM staff WHERE id = 1" >/dev/null 2>&1 && fail "a stylist with bookings could be deleted" || pass "a stylist with bookings still can't be deleted"

exit $FAILED
