-- The weekly "revenue per stylist" report, written straight against the raw documents.
SELECT doc->>'staff' AS stylist,
       sum((doc->>'price')::numeric) AS revenue
FROM bookings_raw
GROUP BY 1
ORDER BY 1;
