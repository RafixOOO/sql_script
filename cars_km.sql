SELECT 
    EXTRACT(YEAR FROM tr_date)::INT AS year,
    SUM(tr_length) AS total_length
FROM 
    transport_rides
WHERE 
    tr_deleted = false
GROUP BY 
    EXTRACT(YEAR FROM tr_date)::INT
ORDER BY 
    year;
