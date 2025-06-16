--sprzedaz -> zakup
--RIN1 -> RPC1
--INV1 -> PCH1
--CSI1 -> CPI1
WITH zakup_tn AS (
    SELECT 
        T3."CardName",
        T3."Country",
        T3."CardCode",
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
        T0."Currency" AS "waluta",
        SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
        MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta"
    FROM (
        SELECT * FROM "TARKON_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "TARKON_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "TARKON_PROD"."RPC1"
    ) T0
    LEFT JOIN "TARKON_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
    WHERE T0."LineStatus" = 'O'
    GROUP BY T3."CardName", T3."Country", T3."CardCode", EXTRACT(YEAR FROM T0."ActDelDate"), T0."Currency"
),
dominant_vat_tn AS (
    SELECT 
        "CardName",
        "Rok",
        "VatGroup" AS "DominantVatGroup"
    FROM (
        SELECT 
            T3."CardName",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            T0."VatGroup",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            ROW_NUMBER() OVER (
                PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") 
                ORDER BY SUM(T0."TotalSumSy") DESC
            ) AS rn
        FROM (
            SELECT * FROM "TARKON_PROD"."PCH1"
            UNION ALL
            SELECT * FROM "TARKON_PROD"."CPI1"
            UNION ALL
            SELECT * FROM "TARKON_PROD"."RPC1"
        ) T0
        LEFT JOIN "TARKON_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
    ) ranked
    WHERE rn = 1
),
lacznosc_roczna_tn AS (
    SELECT 
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        SUM(T0."LineTotal") AS "Wartosc_laczna"
    FROM (
        SELECT * FROM "TARKON_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "TARKON_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "TARKON_PROD"."RPC1"
    ) T0
    WHERE T0."LineStatus" = 'O'
    GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
), zakup_kwartalna_tn AS (
    SELECT 
        T3."CardCode",
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        CEIL(EXTRACT(MONTH FROM T0."ActDelDate") / 3) AS "Kwartal",
        SUM(T0."TotalSumSy") AS "zakup_kwartalna_PLN",
        SUM(T0."TotalFrgn") AS "zakup_kwartalna_EUR"
    FROM (
        SELECT * FROM "TARKON_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "TARKON_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "TARKON_PROD"."RPC1"
    ) T0
    LEFT JOIN "TARKON_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
    WHERE T0."LineStatus" = 'O'
    GROUP BY T3."CardCode", EXTRACT(YEAR FROM T0."ActDelDate"), CEIL(EXTRACT(MONTH FROM T0."ActDelDate") / 3)
), kwartaly_pivot_tn AS (
    SELECT
        "CardCode",
        "Rok",
        MAX(CASE WHEN "Kwartal" = 1 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q1_PLN,
        MAX(CASE WHEN "Kwartal" = 2 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q2_PLN,
        MAX(CASE WHEN "Kwartal" = 3 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q3_PLN,
        MAX(CASE WHEN "Kwartal" = 4 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q4_PLN,
        MAX(CASE WHEN "Kwartal" = 1 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q1_EUR,
        MAX(CASE WHEN "Kwartal" = 2 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q2_EUR,
        MAX(CASE WHEN "Kwartal" = 3 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q3_EUR,
        MAX(CASE WHEN "Kwartal" = 4 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q4_EUR
    FROM zakup_kwartalna_tn
    GROUP BY "CardCode", "Rok"
),
zakup_wl AS (
    SELECT 
        T3."CardName",
        T3."Country",
        T3."CardCode",
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
        T0."Currency" AS "waluta",
        SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
        MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta"
    FROM (
        SELECT * FROM "WILSKO_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "WILSKO_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "WILSKO_PROD"."RPC1"
    ) T0
    LEFT JOIN "WILSKO_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
    WHERE T0."LineStatus" = 'O'
    GROUP BY T3."CardName", T3."Country", T3."CardCode", EXTRACT(YEAR FROM T0."ActDelDate"), T0."Currency"
),
dominant_vat_wl AS (
    SELECT 
        "CardName",
        "Rok",
        "VatGroup" AS "DominantVatGroup"
    FROM (
        SELECT 
            T3."CardName",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            T0."VatGroup",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            ROW_NUMBER() OVER (
                PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") 
                ORDER BY SUM(T0."TotalSumSy") DESC
            ) AS rn
        FROM (
            SELECT * FROM "WILSKO_PROD"."PCH1"
            UNION ALL
            SELECT * FROM "WILSKO_PROD"."CPI1"
            UNION ALL
            SELECT * FROM "WILSKO_PROD"."RPC1"
        ) T0
        LEFT JOIN "WILSKO_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
    ) ranked
    WHERE rn = 1
),
lacznosc_roczna_wl AS (
    SELECT 
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        SUM(T0."LineTotal") AS "Wartosc_laczna"
    FROM (
        SELECT * FROM "WILSKO_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "WILSKO_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "WILSKO_PROD"."RPC1"
    ) T0
    WHERE T0."LineStatus" = 'O'
    GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
), zakup_kwartalna_wl AS (
    SELECT 
        T3."CardCode",
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        CEIL(EXTRACT(MONTH FROM T0."ActDelDate") / 3) AS "Kwartal",
        SUM(T0."TotalSumSy") AS "zakup_kwartalna_PLN",
        SUM(T0."TotalFrgn") AS "zakup_kwartalna_EUR"
    FROM (
        SELECT * FROM "WILSKO_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "WILSKO_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "WILSKO_PROD"."RPC1"
    ) T0
    LEFT JOIN "WILSKO_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
    WHERE T0."LineStatus" = 'O'
    GROUP BY T3."CardCode", EXTRACT(YEAR FROM T0."ActDelDate"), CEIL(EXTRACT(MONTH FROM T0."ActDelDate") / 3)
), kwartaly_pivot_wl AS (
    SELECT
        "CardCode",
        "Rok",
        MAX(CASE WHEN "Kwartal" = 1 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q1_PLN,
        MAX(CASE WHEN "Kwartal" = 2 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q2_PLN,
        MAX(CASE WHEN "Kwartal" = 3 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q3_PLN,
        MAX(CASE WHEN "Kwartal" = 4 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q4_PLN,
        MAX(CASE WHEN "Kwartal" = 1 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q1_EUR,
        MAX(CASE WHEN "Kwartal" = 2 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q2_EUR,
        MAX(CASE WHEN "Kwartal" = 3 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q3_EUR,
        MAX(CASE WHEN "Kwartal" = 4 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q4_EUR
    FROM zakup_kwartalna_wl
    GROUP BY "CardCode", "Rok"
),
zakup_tp AS (
    SELECT 
        T3."CardName",
        T3."Country",
        T3."CardCode",
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
        T0."Currency" AS "waluta",
        SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
        MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta"
    FROM (
        SELECT * FROM "TARKONPROJEKT_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "TARKONPROJEKT_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "TARKONPROJEKT_PROD"."RPC1"
    ) T0
    LEFT JOIN "TARKONPROJEKT_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
    WHERE T0."LineStatus" = 'O'
    GROUP BY T3."CardName", T3."Country", T3."CardCode", EXTRACT(YEAR FROM T0."ActDelDate"), T0."Currency"
),
dominant_vat_tp AS (
    SELECT 
        "CardName",
        "Rok",
        "VatGroup" AS "DominantVatGroup"
    FROM (
        SELECT 
            T3."CardName",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            T0."VatGroup",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            ROW_NUMBER() OVER (
                PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") 
                ORDER BY SUM(T0."TotalSumSy") DESC
            ) AS rn
        FROM (
            SELECT * FROM "TARKONPROJEKT_PROD"."PCH1"
            UNION ALL
            SELECT * FROM "TARKONPROJEKT_PROD"."CPI1"
            UNION ALL
            SELECT * FROM "TARKONPROJEKT_PROD"."RPC1"
        ) T0
        LEFT JOIN "TARKONPROJEKT_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
    ) ranked
    WHERE rn = 1
),
lacznosc_roczna_tp AS (
    SELECT 
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        SUM(T0."LineTotal") AS "Wartosc_laczna"
    FROM (
        SELECT * FROM "TARKONPROJEKT_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "TARKONPROJEKT_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "TARKONPROJEKT_PROD"."RPC1"
    ) T0
    WHERE T0."LineStatus" = 'O'
    GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
), zakup_kwartalna_tp AS (
    SELECT 
        T3."CardCode",
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        CEIL(EXTRACT(MONTH FROM T0."ActDelDate") / 3) AS "Kwartal",
        SUM(T0."TotalSumSy") AS "zakup_kwartalna_PLN",
        SUM(T0."TotalFrgn") AS "zakup_kwartalna_EUR"
    FROM (
        SELECT * FROM "TARKONPROJEKT_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "TARKONPROJEKT_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "TARKONPROJEKT_PROD"."RPC1"
    ) T0
    LEFT JOIN "TARKONPROJEKT_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
    WHERE T0."LineStatus" = 'O'
    GROUP BY T3."CardCode", EXTRACT(YEAR FROM T0."ActDelDate"), CEIL(EXTRACT(MONTH FROM T0."ActDelDate") / 3)
), kwartaly_pivot_tp AS (
    SELECT
        "CardCode",
        "Rok",
        MAX(CASE WHEN "Kwartal" = 1 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q1_PLN,
        MAX(CASE WHEN "Kwartal" = 2 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q2_PLN,
        MAX(CASE WHEN "Kwartal" = 3 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q3_PLN,
        MAX(CASE WHEN "Kwartal" = 4 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q4_PLN,
        MAX(CASE WHEN "Kwartal" = 1 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q1_EUR,
        MAX(CASE WHEN "Kwartal" = 2 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q2_EUR,
        MAX(CASE WHEN "Kwartal" = 3 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q3_EUR,
        MAX(CASE WHEN "Kwartal" = 4 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q4_EUR
    FROM zakup_kwartalna_tp
    GROUP BY "CardCode", "Rok"
),
zakup_tm AS (
    SELECT 
        T3."CardName",
        T3."Country",
        T3."CardCode",
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
        T0."Currency" AS "waluta",
        SUM(T0."TotalFrgn") AS "Wartosc_sprzedarzy_eur",
        MIN(EXTRACT(YEAR FROM T0."ActDelDate")) OVER (PARTITION BY T3."CardName") AS "Najstarszy_rok_kontrahenta"
    FROM (
        SELECT * FROM "TARKON_MEBU_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "TARKON_MEBU_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "TARKON_MEBU_PROD"."RPC1"
    ) T0
    LEFT JOIN "TARKON_MEBU_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
    WHERE T0."LineStatus" = 'O'
    GROUP BY T3."CardName", T3."Country", T3."CardCode", EXTRACT(YEAR FROM T0."ActDelDate"), T0."Currency"
),
dominant_vat_tm AS (
    SELECT 
        "CardName",
        "Rok",
        "VatGroup" AS "DominantVatGroup"
    FROM (
        SELECT 
            T3."CardName",
            EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
            T0."VatGroup",
            SUM(T0."TotalSumSy") AS "Wartosc_sprzedarzy",
            ROW_NUMBER() OVER (
                PARTITION BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate") 
                ORDER BY SUM(T0."TotalSumSy") DESC
            ) AS rn
        FROM (
            SELECT * FROM "TARKON_MEBU_PROD"."PCH1"
            UNION ALL
            SELECT * FROM "TARKON_MEBU_PROD"."CPI1"
            UNION ALL
            SELECT * FROM "TARKON_MEBU_PROD"."RPC1"
        ) T0
        LEFT JOIN "TARKON_MEBU_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
        WHERE T0."LineStatus" = 'O'
        GROUP BY T3."CardName", EXTRACT(YEAR FROM T0."ActDelDate"), T0."VatGroup"
    ) ranked
    WHERE rn = 1
),
lacznosc_roczna_tm AS (
    SELECT 
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        SUM(T0."LineTotal") AS "Wartosc_laczna"
    FROM (
        SELECT * FROM "TARKON_MEBU_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "TARKON_MEBU_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "TARKON_MEBU_PROD"."RPC1"
    ) T0
    WHERE T0."LineStatus" = 'O'
    GROUP BY EXTRACT(YEAR FROM T0."ActDelDate")
), zakup_kwartalna_tm AS (
    SELECT 
        T3."CardCode",
        EXTRACT(YEAR FROM T0."ActDelDate") AS "Rok",
        CEIL(EXTRACT(MONTH FROM T0."ActDelDate") / 3) AS "Kwartal",
        SUM(T0."TotalSumSy") AS "zakup_kwartalna_PLN",
        SUM(T0."TotalFrgn") AS "zakup_kwartalna_EUR"
    FROM (
        SELECT * FROM "TARKON_MEBU_PROD"."PCH1"
        UNION ALL
        SELECT * FROM "TARKON_MEBU_PROD"."CPI1"
        UNION ALL
        SELECT * FROM "TARKON_MEBU_PROD"."RPC1"
    ) T0
    LEFT JOIN "TARKON_MEBU_PROD"."OCRD" T3 ON T0."BaseCard" = T3."CardCode"
    WHERE T0."LineStatus" = 'O'
    GROUP BY T3."CardCode", EXTRACT(YEAR FROM T0."ActDelDate"), CEIL(EXTRACT(MONTH FROM T0."ActDelDate") / 3)
), kwartaly_pivot_tm AS (
    SELECT
        "CardCode",
        "Rok",
        MAX(CASE WHEN "Kwartal" = 1 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q1_PLN,
        MAX(CASE WHEN "Kwartal" = 2 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q2_PLN,
        MAX(CASE WHEN "Kwartal" = 3 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q3_PLN,
        MAX(CASE WHEN "Kwartal" = 4 THEN "zakup_kwartalna_PLN" ELSE 0 END) AS Q4_PLN,
        MAX(CASE WHEN "Kwartal" = 1 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q1_EUR,
        MAX(CASE WHEN "Kwartal" = 2 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q2_EUR,
        MAX(CASE WHEN "Kwartal" = 3 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q3_EUR,
        MAX(CASE WHEN "Kwartal" = 4 THEN "zakup_kwartalna_EUR" ELSE 0 END) AS Q4_EUR
    FROM zakup_kwartalna_tm
    GROUP BY "CardCode", "Rok"
)
SELECT
    'TN' AS firma,
    s."CardCode",
    s."CardName",
    s."Wartosc_sprzedarzy" AS zakup_netto_pln,
    s."Wartosc_sprzedarzy_eur",
    s."waluta",
    s."Country",
    d."DominantVatGroup",
    s."Rok",
    l."Wartosc_laczna",
    ROUND((s."Wartosc_sprzedarzy" / l."Wartosc_laczna") * 100, 2) AS "Udzial_procent",
    s."Rok" - s."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy",
    k."Q1_PLN", k."Q2_PLN", k."Q3_PLN", k."Q4_PLN",
    k."Q1_EUR", k."Q2_EUR", k."Q3_EUR", k."Q4_EUR"
FROM zakup_tn s
JOIN dominant_vat_tn d ON s."CardName" = d."CardName" AND s."Rok" = d."Rok"
JOIN lacznosc_roczna_tn l ON s."Rok" = l."Rok"
LEFT JOIN kwartaly_pivot_tn k ON s."CardCode" = k."CardCode" AND s."Rok" = k."Rok"
UNION ALL
SELECT
    'WL' AS firma,
    s."CardCode",
    s."CardName",
    s."Wartosc_sprzedarzy" AS zakup_netto_pln,
    s."Wartosc_sprzedarzy_eur",
    s."waluta",
    s."Country",
    d."DominantVatGroup",
    s."Rok",
    l."Wartosc_laczna",
    ROUND((s."Wartosc_sprzedarzy" / l."Wartosc_laczna") * 100, 2) AS "Udzial_procent",
    s."Rok" - s."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy",
    k."Q1_PLN", k."Q2_PLN", k."Q3_PLN", k."Q4_PLN",
    k."Q1_EUR", k."Q2_EUR", k."Q3_EUR", k."Q4_EUR"
FROM zakup_wl s
JOIN dominant_vat_wl d ON s."CardName" = d."CardName" AND s."Rok" = d."Rok"
JOIN lacznosc_roczna_wl l ON s."Rok" = l."Rok"
LEFT JOIN kwartaly_pivot_wl k ON s."CardCode" = k."CardCode" AND s."Rok" = k."Rok"
UNION ALL
SELECT
    'TP' AS firma,
    s."CardCode",
    s."CardName",
    s."Wartosc_sprzedarzy" AS zakup_netto_pln,
    s."Wartosc_sprzedarzy_eur",
    s."waluta",
    s."Country",
    d."DominantVatGroup",
    s."Rok",
    l."Wartosc_laczna",
    ROUND((s."Wartosc_sprzedarzy" / l."Wartosc_laczna") * 100, 2) AS "Udzial_procent",
    s."Rok" - s."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy",
    k."Q1_PLN", k."Q2_PLN", k."Q3_PLN", k."Q4_PLN",
    k."Q1_EUR", k."Q2_EUR", k."Q3_EUR", k."Q4_EUR"
FROM zakup_tp s
JOIN dominant_vat_tp d ON s."CardName" = d."CardName" AND s."Rok" = d."Rok"
JOIN lacznosc_roczna_tp l ON s."Rok" = l."Rok"
LEFT JOIN kwartaly_pivot_tp k ON s."CardCode" = k."CardCode" AND s."Rok" = k."Rok"
UNION ALL
SELECT
    'TM' AS firma,
    s."CardCode",
    s."CardName",
    s."Wartosc_sprzedarzy" AS zakup_netto_pln,
    s."Wartosc_sprzedarzy_eur",
    s."waluta",
    s."Country",
    d."DominantVatGroup",
    s."Rok",
    l."Wartosc_laczna",
    ROUND((s."Wartosc_sprzedarzy" / l."Wartosc_laczna") * 100, 2) AS "Udzial_procent",
    s."Rok" - s."Najstarszy_rok_kontrahenta" AS "Lata_od_rozpoczecia_wspolpracy",
    k."Q1_PLN", k."Q2_PLN", k."Q3_PLN", k."Q4_PLN",
    k."Q1_EUR", k."Q2_EUR", k."Q3_EUR", k."Q4_EUR"
FROM zakup_tm s
JOIN dominant_vat_tm d ON s."CardName" = d."CardName" AND s."Rok" = d."Rok"
JOIN lacznosc_roczna_tm l ON s."Rok" = l."Rok"
LEFT JOIN kwartaly_pivot_tm k ON s."CardCode" = k."CardCode" AND s."Rok" = k."Rok"