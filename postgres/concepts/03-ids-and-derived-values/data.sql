-- Until now, Trimly's London and Dubai salons each had their own database. Both numbered bookings with serial ids from 1.
-- Handwritten. Each booking stores price, tip, and the total the till app typed in. The Dubai tablet app had a bug in the total.
DROP TABLE IF EXISTS bookings, london_bookings, dubai_bookings CASCADE;

CREATE TABLE london_bookings (
  id             serial PRIMARY KEY,
  customer_email text NOT NULL,
  price          numeric(8,2) NOT NULL,
  tip            numeric(8,2) NOT NULL,
  total          numeric(8,2) NOT NULL
);
INSERT INTO london_bookings (customer_email, price, tip, total) VALUES
  ('ravi@example.com',  25.00, 3.00, 28.00),
  ('meera@example.com', 60.00, 0.00, 60.00),
  ('tom@example.com',   25.00, 5.00, 30.00),
  ('lena@example.com',  12.50, 2.50, 15.00);

CREATE TABLE dubai_bookings (
  id             serial PRIMARY KEY,
  customer_email text NOT NULL,
  price          numeric(8,2) NOT NULL,
  tip            numeric(8,2) NOT NULL,
  total          numeric(8,2) NOT NULL
);
INSERT INTO dubai_bookings (customer_email, price, tip, total) VALUES
  ('omar@example.com',  150.00, 20.00, 170.00),
  ('sara@example.com',   90.00, 10.00,  90.00),
  ('omar@example.com',   75.50,  0.00,  75.50),
  ('aisha@example.com',  99.90, 10.10, 100.00);
