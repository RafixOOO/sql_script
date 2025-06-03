SELECT
    o.nazwisko,
    o.imie,
    l.in_out AS Wej_Wyj,
    CAST(l.data_czas AS DATE) AS datewej
FROM 
    users o
JOIN 
    att_log l ON l.idx_osoby = o.idx_osoby
JOIN 
    dzialy d ON o.idx_dzialu = d.idx_dzialu
WHERE 
    l.in_out IN ('0', '2')
    AND l.aktywny = 'true'
    AND l.idx_device = '20'
    AND d.nazwa LIKE '%Produkcja%'
    AND CAST(l.data_czas AS DATE) > '2024.04.17'
GROUP BY 
    o.nazwisko, o.imie, l.in_out, CAST(l.data_czas AS DATE)
                           
                           
                           
                           
                           
                           
                           
                           
                           
