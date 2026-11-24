#!/usr/bin/env bash
# Reloads the payments, runs your solution.sql, then checks the column types and the converted values.
cd "$(dirname "$0")" && export PGDATABASE=learn_02 && . ../../infra/lib.sh

psql -q -f data.sql >/dev/null
psql -q -v ON_ERROR_STOP=1 -f solution.sql || fail "solution.sql stopped with an error"
q() { psql -Atc "$1" 2>/dev/null; }

got=$(q "select count(*) from payments")
[ "$got" = 9 ] && pass "all 9 payments still there" || fail "payments has ${got:-no} rows (want 9)"

got=$(q "select data_type from information_schema.columns where table_name = 'payments' and column_name = 'amount'")
[ "$got" = numeric ] && pass "amount is numeric" || fail "amount is '${got}' (want an exact type: numeric)"

got=$(q "select sum(amount) = 75.00 from payments where branch = 'LDN' and id between 1 and 5")
[ "$got" = t ] && pass "London's 27 March total is exactly 75.00" || fail "London's 27 March total is not exactly 75.00"

got=$(q "select data_type from information_schema.columns where table_name = 'payments' and column_name = 'paid_at'")
[ "$got" = "timestamp with time zone" ] && pass "paid_at is timestamp with time zone" || fail "paid_at is '${got}' (want timestamp with time zone)"

check_moment() {  # id, expected UTC moment, description
  got=$(q "select paid_at = '$2'::timestamptz from payments where id = $1")
  [ "$got" = t ] && pass "payment $1 ($3) is $2" || fail "payment $1 ($3) is $(q "select paid_at from payments where id = $1") (want $2)"
}
check_moment 1 "2026-03-27 10:00+00" "London, before the clock change"
check_moment 7 "2026-03-27 20:30+00" "Dubai, 00:30 local on the 28th"
check_moment 8 "2026-03-30 08:00+00" "London, after the clock change"

exit $FAILED
