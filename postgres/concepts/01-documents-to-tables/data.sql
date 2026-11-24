-- Trimly's bookings as they came out of the old MongoDB: one JSON document per booking, copied as-is.
-- Handwritten to show the kinds of mess a schemaless store collects as apps and forms change over the years.
DROP TABLE IF EXISTS bookings, customers, staff, bookings_raw CASCADE;

CREATE TABLE bookings_raw (
  id  int PRIMARY KEY,
  doc jsonb NOT NULL
);

INSERT INTO bookings_raw VALUES
  (1, '{"customer": {"name": "Ravi Kumar", "email": "ravi@example.com"}, "staff": "Asha", "service": "Haircut", "price": 25.00, "starts_at": "2026-03-02T10:00:00Z"}'),
  (2, '{"customer": {"name": "Meera Iyer", "email": "meera@example.com"}, "staff": "Asha", "service": "Colour", "price": "60.00", "starts_at": "2026-03-02T11:00:00Z"}'),
  (3, '{"customer_name": "Tom Hughes", "customer_email": "tom@example.com", "staff": "Ben", "service": "Haircut", "price": 25, "starts_at": "2026-03-02T10:00:00Z"}'),
  (4, '{"customer": {"name": "Ravi Kumar", "email": "ravi@example.com"}, "staff": "asha ", "service": "Beard trim", "price": 12.5, "starts_at": "2026-03-03T09:30:00Z"}'),
  (5, '{"customer": {"name": "Lena Park", "email": "lena@example.com"}, "stylist": "Ben", "service": "Colour", "price": 60, "starts_at": "2026-03-03T14:00:00Z"}'),
  (6, '{"customer": {"name": "Meera Iyer", "email": "meera@example.com"}, "staff": "Ben", "service": "Haircut", "price": 25, "starts_at": "2026-03-04T16:00:00Z"}'),
  (7, '{"customer": {"name": "Tom Hughes", "email": "tom@example.com"}, "staff": "Asha", "service": "Haircut", "price": "25", "starts_at": "2026-03-05T10:00:00Z"}'),
  (8, '{"customer_name": "Lena Park", "customer_email": "lena@example.com", "stylist": "asha", "service": "Haircut", "price": 25, "starts_at": "2026-03-05T12:00:00Z"}');
