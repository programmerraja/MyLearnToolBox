-- Trimly's payments table from the early days: amounts as floating point, times as local time without a zone.
-- Handwritten. Trimly has two branches: London (clocks go forward on 2026-03-29) and Dubai (no daylight saving).
DROP TABLE IF EXISTS payments, bank_settlements, branches CASCADE;

CREATE TABLE branches (
  code text PRIMARY KEY,
  city text NOT NULL,
  tz   text NOT NULL
);
INSERT INTO branches VALUES
  ('LDN', 'London', 'Europe/London'),
  ('DXB', 'Dubai',  'Asia/Dubai');

CREATE TABLE payments (
  id      int PRIMARY KEY,
  branch  text NOT NULL REFERENCES branches (code),
  amount  double precision NOT NULL,
  paid_at timestamp NOT NULL
);
INSERT INTO payments VALUES
  (1, 'LDN', 24.90,  '2026-03-27 10:00'),
  (2, 'LDN', 24.90,  '2026-03-27 11:30'),
  (3, 'LDN', 24.90,  '2026-03-27 15:00'),
  (4, 'LDN', 0.10,   '2026-03-27 15:05'),
  (5, 'LDN', 0.20,   '2026-03-27 16:40'),
  (6, 'DXB', 150.00, '2026-03-27 19:00'),
  (7, 'DXB', 75.50,  '2026-03-28 00:30'),
  (8, 'LDN', 25.00,  '2026-03-30 09:00'),
  (9, 'DXB', 99.90,  '2026-03-30 10:15');

-- What the bank actually paid out per branch per local day.
CREATE TABLE bank_settlements (
  branch text NOT NULL REFERENCES branches (code),
  day    date NOT NULL,
  total  numeric(10,2) NOT NULL,
  PRIMARY KEY (branch, day)
);
INSERT INTO bank_settlements VALUES
  ('LDN', '2026-03-27', 75.00),
  ('DXB', '2026-03-27', 150.00),
  ('DXB', '2026-03-28', 75.50),
  ('LDN', '2026-03-30', 25.00),
  ('DXB', '2026-03-30', 99.90);
