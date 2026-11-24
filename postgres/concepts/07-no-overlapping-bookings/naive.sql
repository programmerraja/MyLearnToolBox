-- The booking code shared by Trimly's web app, mobile app and reception tablet.
-- 1. Is the slot free?  2. Take the deposit (pg_sleep stands for the ~300 ms call to the payment provider).  3. Save the booking.
-- Run: psql learn_07 -v staff=2 -v slot_start='2027-06-15 10:00+00' -v slot_end='2027-06-15 11:00+00' -v email=ravi@example.com -f naive.sql

SELECT NOT EXISTS (
  SELECT 1 FROM bookings
  WHERE staff_id = :staff AND status = 'confirmed'
    AND starts_at < :'slot_end' AND ends_at > :'slot_start'
) AS is_free \gset

SELECT pg_sleep(0.3);

\if :is_free
INSERT INTO bookings (staff_id, customer_email, starts_at, ends_at)
VALUES (:staff, :'email', :'slot_start', :'slot_end');
\endif
