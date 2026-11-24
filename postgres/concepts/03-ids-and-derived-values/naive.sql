-- The merge script the team wrote: copy both salons into one bookings table, keeping the old ids.
DROP TABLE IF EXISTS bookings;
CREATE TABLE bookings (
  id             int PRIMARY KEY,
  branch         text NOT NULL,
  customer_email text NOT NULL,
  price          numeric(8,2) NOT NULL,
  tip            numeric(8,2) NOT NULL,
  total          numeric(8,2) NOT NULL
);
INSERT INTO bookings SELECT id, 'LDN', customer_email, price, tip, total FROM london_bookings;
INSERT INTO bookings SELECT id, 'DXB', customer_email, price, tip, total FROM dubai_bookings;

-- Revenue per salon, from the stored totals.
SELECT branch, sum(total) AS revenue FROM bookings GROUP BY branch ORDER BY branch;
