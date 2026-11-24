-- 1. Finance's reconciliation: our daily total per branch vs what the bank paid out. Every row here is a mismatch someone has to chase.
SELECT p.branch, p.paid_at::date AS day, sum(p.amount) AS our_total, s.total AS bank_total
FROM payments p
JOIN bank_settlements s ON s.branch = p.branch AND s.day = p.paid_at::date
GROUP BY p.branch, p.paid_at::date, s.total
HAVING sum(p.amount) <> s.total;

-- 2. Head office dashboard: payments per day, in UTC (head office compares both branches on one clock).
SELECT paid_at::date AS utc_day, count(*) AS payments
FROM payments
GROUP BY 1
ORDER BY 1;
