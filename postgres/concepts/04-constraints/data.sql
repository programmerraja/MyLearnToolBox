-- Trimly's customers and bookings tables, created in a hurry with no rules at all.
-- Handwritten. The bad rows are the kinds a buggy import and an old mobile app version actually leave behind.
DROP TABLE IF EXISTS bookings, customers CASCADE;

CREATE TABLE customers (
  id    int PRIMARY KEY,
  name  text,
  email text
);
INSERT INTO customers VALUES
  (1, 'Ravi Kumar', 'ravi@example.com'),
  (2, 'Meera Iyer', 'meera@example.com'),
  (3, 'Tom Hughes', 'tom@example.com'),
  (4, 'Lena Park',  'lena@example.com'),
  (5, 'Ravi Kumar', 'RAVI@example.com');

CREATE TABLE bookings (
  id          int PRIMARY KEY,
  customer_id int,
  starts_at   timestamptz,
  price       numeric(8,2),
  status      text
);
INSERT INTO bookings VALUES
  (1, 1,  '2026-03-02 10:00+00', 25.00,  'confirmed'),
  (2, 2,  '2026-03-02 11:00+00', 60.00,  'confirmed'),
  (3, 3,  '2026-03-02 10:00+00', 25.00,  'cancelled'),
  (4, 5,  '2026-03-03 09:30+00', 12.50,  'confirmed'),
  (5, 4,  '2026-03-03 14:00+00', 60.00,  'completed'),
  (6, 99, '2026-03-04 16:00+00', 25.00,  'confirmed'),
  (7, 2,  NULL,                  25.00,  'confirmed'),
  (8, 3,  '2026-03-05 10:00+00', -25.00, 'confirmed'),
  (9, 4,  '2026-03-05 12:00+00', 25.00,  'Confrimed');
