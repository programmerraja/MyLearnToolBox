-- Finance's booking spreadsheet, imported as one wide table: every row repeats the customer, stylist and service details.
-- Handwritten. Ravi changed his email in February; the haircut and colour prices went up in March.
DROP TABLE IF EXISTS bookings, services, staff, customers, booking_lines CASCADE;

CREATE TABLE booking_lines (
  booking_id     int PRIMARY KEY,
  customer_name  text,
  customer_email text,
  staff_name     text,
  service_name   text,
  service_price  numeric(8,2),
  starts_at      timestamptz
);
INSERT INTO booking_lines VALUES
  (1, 'Ravi Kumar', 'ravi@example.com',   'Asha', 'Haircut',    25.00, '2026-01-10 10:00+00'),
  (2, 'Meera Iyer', 'meera@example.com',  'Asha', 'Colour',     60.00, '2026-01-10 11:00+00'),
  (3, 'Ravi Kumar', 'ravi@example.com',   'Ben',  'Beard trim', 12.50, '2026-01-17 09:30+00'),
  (4, 'Tom Hughes', 'tom@example.com',    'Ben',  'Haircut',    25.00, '2026-01-24 10:00+00'),
  (5, 'Meera Iyer', 'meera@example.com',  'Ben',  'Haircut',    25.00, '2026-02-07 16:00+00'),
  (6, 'Ravi Kumar', 'ravi.k@example.com', 'Asha', 'Haircut',    28.00, '2026-03-02 10:00+00'),
  (7, 'Tom Hughes', 'tom@example.com',    'Asha', 'Colour',     65.00, '2026-03-05 12:00+00'),
  (8, 'Ravi Kumar', 'ravi@example.com',   'Ben',  'Beard trim', 12.50, '2026-03-09 09:30+00');
