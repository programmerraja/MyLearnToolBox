-- Trimly's customers, stylists, bookings and marketing consents, linked by foreign keys with the default rules.
-- Handwritten. Lena (customer 4) has asked Trimly to delete her account.
DROP TABLE IF EXISTS consents, bookings, staff, customers CASCADE;

CREATE TABLE customers (
  id    int PRIMARY KEY,
  name  text NOT NULL,
  email text NOT NULL UNIQUE
);
INSERT INTO customers VALUES
  (1, 'Ravi Kumar', 'ravi@example.com'),
  (2, 'Meera Iyer', 'meera@example.com'),
  (3, 'Tom Hughes', 'tom@example.com'),
  (4, 'Lena Park',  'lena@example.com');

CREATE TABLE staff (
  id   int PRIMARY KEY,
  name text NOT NULL
);
INSERT INTO staff VALUES (1, 'Asha'), (2, 'Ben');

CREATE TABLE bookings (
  id          int PRIMARY KEY,
  customer_id int NOT NULL REFERENCES customers (id),
  staff_id    int NOT NULL REFERENCES staff (id),
  starts_at   timestamptz NOT NULL,
  price       numeric(8,2) NOT NULL
);
INSERT INTO bookings VALUES
  (1, 1, 1, '2026-03-02 10:00+00', 25.00),
  (2, 2, 1, '2026-03-02 11:00+00', 60.00),
  (3, 4, 2, '2026-03-03 14:00+00', 60.00),
  (4, 3, 2, '2026-03-04 10:00+00', 25.00),
  (5, 4, 1, '2026-03-05 12:00+00', 25.00),
  (6, 1, 2, '2026-03-09 09:30+00', 12.50);

CREATE TABLE consents (
  customer_id int NOT NULL REFERENCES customers (id),
  channel     text NOT NULL,
  given_at    timestamptz NOT NULL,
  PRIMARY KEY (customer_id, channel)
);
INSERT INTO consents VALUES
  (1, 'email', '2025-11-01 09:00+00'),
  (2, 'sms',   '2025-12-03 18:20+00'),
  (4, 'email', '2026-01-15 12:00+00'),
  (4, 'sms',   '2026-01-15 12:00+00');
