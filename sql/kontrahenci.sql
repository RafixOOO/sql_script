SELECT
	'TN' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "TARKON_PROD"."INV1" T0
        LEFT JOIN "TARKON_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "TARKON_PROD"."INV1" T0
                LEFT JOIN "TARKON_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "TARKON_PROD"."INV1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'TN' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "TARKON_PROD"."CSI1" T0
        LEFT JOIN "TARKON_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "TARKON_PROD"."CSI1" T0
                LEFT JOIN "TARKON_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "TARKON_PROD"."CSI1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'TN' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "TARKON_PROD"."RIN1" T0
        LEFT JOIN "TARKON_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "TARKON_PROD"."RIN1" T0
                LEFT JOIN "TARKON_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "TARKON_PROD"."RIN1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'WL' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "WILSKO_PROD"."INV1" T0
        LEFT JOIN "WILSKO_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "WILSKO_PROD"."INV1" T0
                LEFT JOIN "WILSKO_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "WILSKO_PROD"."INV1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'WL' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "WILSKO_PROD"."CSI1" T0
        LEFT JOIN "WILSKO_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "WILSKO_PROD"."CSI1" T0
                LEFT JOIN "WILSKO_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "WILSKO_PROD"."CSI1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'WL' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "WILSKO_PROD"."RIN1" T0
        LEFT JOIN "WILSKO_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "WILSKO_PROD"."RIN1" T0
                LEFT JOIN "WILSKO_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "WILSKO_PROD"."RIN1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'TP' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "TARKONPROJEKT_PROD"."INV1" T0
        LEFT JOIN "TARKONPROJEKT_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "TARKONPROJEKT_PROD"."INV1" T0
                LEFT JOIN "TARKONPROJEKT_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "TARKONPROJEKT_PROD"."INV1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'TP' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "TARKONPROJEKT_PROD"."CSI1" T0
        LEFT JOIN "TARKONPROJEKT_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "TARKONPROJEKT_PROD"."CSI1" T0
                LEFT JOIN "TARKONPROJEKT_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "TARKONPROJEKT_PROD"."CSI1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'TP' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "TARKONPROJEKT_PROD"."RIN1" T0
        LEFT JOIN "TARKONPROJEKT_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "TARKONPROJEKT_PROD"."RIN1" T0
                LEFT JOIN "TARKONPROJEKT_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "TARKONPROJEKT_PROD"."RIN1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'TM' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "TARKON_MEBU_PROD"."INV1" T0
        LEFT JOIN "TARKON_MEBU_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "TARKON_MEBU_PROD"."INV1" T0
                LEFT JOIN "TARKON_MEBU_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "TARKON_MEBU_PROD"."INV1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'TM' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "TARKON_MEBU_PROD"."CSI1" T0
        LEFT JOIN "TARKON_MEBU_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "TARKON_MEBU_PROD"."CSI1" T0
                LEFT JOIN "TARKON_MEBU_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "TARKON_MEBU_PROD"."CSI1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'
UNION ALL
SELECT
	'TM' AS firma,
	m."CardCode",
    m."CardName",
    m."Wartosc_sprzedarzy" as sprzedaz_netto_pln,
    m."Wartosc_sprzedarzy_eur" ,
    m."waluta",
    m."Country",
    d."DominantVatGroup",
    m."Rok",
    ROUND(
        (m."Wartosc_sprzedarzy" / total."Wartosc_laczna") * 100, 
        2
    ) AS "Udzial_procent",
    m."Rok" - m."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy"
FROM
    (
        SELECT
            T3."CardName",
            T3."Country",
            T3."CardCode",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            T0."Currency" AS "waluta",
            SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
            MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najnowszy_rok_kontrahenta",
            MIN(T0."ActDelDate") AS "Najstarsza_data",
            MAX(T0."ActDelDate") AS "Najnowsza_data",
            MAX(EXTRACT(YEAR FROM T0."ActDelDate")) - MIN(EXTRACT(YEAR FROM T0."ActDelDate")) AS "Rok_Roznica"
        FROM "TARKON_MEBU_PROD"."RIN1" T0
        LEFT JOIN "TARKON_MEBU_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", T3."Country", EXTRACT(YEAR FROM T0."ActDelDate"),T0."Currency",T3."CardCode"
    ) m
JOIN
    (
        SELECT
            "CardName",
            "Rok",
            "VatGroup" AS "DominantVatGroup"
        FROM
            (
                SELECT
                    T3."CardName",
                    EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
                    T0."VatGroup",
                    SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
                    ROW_NUMBER() OVER (PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") ORDER BY SUM(T0."TotalSumSy") DESC) AS rn
                FROM "TARKON_MEBU_PROD"."RIN1" T0
                LEFT JOIN "TARKON_MEBU_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
                WHERE T0."LineStatus" = 'O'
                GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
            ) ranked
        WHERE rn = 1
    ) d
ON m."CardName" = d."CardName" AND m."Rok" = d."Rok"
JOIN
    (
        SELECT 
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            SUM(T0."LineTotal") AS "Wartosc_laczna"
        FROM "TARKON_MEBU_PROD"."RIN1" T0
        WHERE T0."LineStatus" = 'O'
        GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
    ) total
ON m."Rok" = total."Rok"
--WHERE m."CardName"='Iris Industry Solutions N.V.'


