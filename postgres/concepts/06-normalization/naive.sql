-- 1. Send each customer their booking summary: one email address per customer, please.
SELECT customer_name, customer_email, count(*) AS bookings
FROM booking_lines
GROUP BY customer_name, customer_email
ORDER BY customer_name;

-- 2. The price list for the website, read from the bookings.
SELECT DISTINCT service_name, service_price
FROM booking_lines
ORDER BY service_name, service_price;
