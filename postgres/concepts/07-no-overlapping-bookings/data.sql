-- Trimly's London salon: 6 stylists, one-hour appointments over two weeks in June 2027, about 70% of slots booked, 10% cancelled.
-- Generated with a fixed seed so every run gives the same diary.
DROP TABLE IF EXISTS bookings, staff CASCADE;

CREATE TABLE staff (
  id   int PRIMARY KEY,
  name text NOT NULL
);
INSERT INTO staff VALUES (1, 'Asha'), (2, 'Ben'), (3, 'Chen'), (4, 'Dara'), (5, 'Eli'), (6, 'Farah');

CREATE TABLE bookings (
  id             bigserial PRIMARY KEY,
  staff_id       int NOT NULL REFERENCES staff (id),
  customer_email text NOT NULL,
  starts_at      timestamptz NOT NULL,
  ends_at        timestamptz NOT NULL,
  status         text NOT NULL DEFAULT 'confirmed'
);

SELECT setseed(0.42);
INSERT INTO bookings (staff_id, customer_email, starts_at, ends_at, status)
SELECT s, 'customer' || (1 + floor(random() * 300))::int || '@example.com', d + t, d + t + interval '1 hour',
       CASE WHEN random() < 0.1 THEN 'cancelled' ELSE 'confirmed' END
FROM generate_series(1, 6) AS s,
     generate_series(timestamptz '2027-06-01 00:00+00', timestamptz '2027-06-12 00:00+00', interval '1 day') AS d,
     unnest(ARRAY[interval '9 hours', interval '10 hours 30 minutes', interval '12 hours',
                  interval '14 hours', interval '15 hours 30 minutes', interval '17 hours']) AS t
WHERE random() < 0.7
ORDER BY d, t, s;
