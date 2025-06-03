SELECT
    COUNT(DISTINCT CASE WHEN l.in_out = '0' THEN o.idx_osoby END) -
    COUNT(DISTINCT CASE WHEN l.in_out = '1' THEN o.idx_osoby END) AS diff_count
FROM users o
JOIN att_log l ON l.idx_osoby = o.idx_osoby
JOIN dzialy d ON o.idx_dzialu = d.idx_dzialu
WHERE
    l.aktywny = 'true'
    AND l.idx_device IN ('37', '1', '38', '5', '2', '43', '42', '4', '6', '3')
    AND d.nazwa LIKE '%Produkcja%'
    AND CAST(l.data_czas AS DATE) = CURRENT_DATE;
