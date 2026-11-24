-- What the apps do today: insert whatever they're given. Each of these is accepted.
INSERT INTO bookings VALUES (20, 999, '2026-04-01 10:00+00', 25.00, 'confirmed');  -- customer 999 doesn't exist
INSERT INTO bookings VALUES (21, 1,   '2026-04-01 11:00+00', -5.00, 'confirmed');  -- negative price
INSERT INTO customers VALUES (20, 'Meera Iyer', 'Meera@Example.com');              -- Meera signs up a second time

-- Weekly revenue per customer: bookings of a customer that doesn't exist silently disappear from it.
SELECT c.name, sum(b.price) AS revenue
FROM bookings b JOIN customers c ON c.id = b.customer_id
WHERE b.status <> 'cancelled'
GROUP BY c.name
ORDER BY c.name;
