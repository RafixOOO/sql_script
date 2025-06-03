WITH OPCHData AS (
SELECT
	EXTRACT(YEAR
FROM
	T0."DocDueDate") AS Rok,
	EXTRACT(MONTH
FROM
	T0."DocDueDate") AS Miesiac,
	T1."Project" AS Projekty,
	SUM(T1."LineTotal") AS Suma
FROM
	"TARKON_PROD"."OPCH" T0
INNER JOIN 
        "TARKON_PROD"."PCH1" T1 ON
	T0."DocEntry" = T1."DocEntry"
WHERE
	T1."LineStatus" = 'O'
	AND T1."Project" != ''
	AND T1."Project" != 'KO'
GROUP BY
	EXTRACT(YEAR
FROM
	T0."DocDueDate"),
	EXTRACT(MONTH
FROM
	T0."DocDueDate"),
	T1."Project"
),
OCPIData AS (
SELECT
	EXTRACT(YEAR
FROM
	T0."DocDueDate") AS Rok,
	EXTRACT(MONTH
FROM
	T0."DocDueDate") AS Miesiac,
	T1."Project" AS Projekty,
	SUM(T1."LineTotal") AS Suma
FROM
	"TARKON_PROD"."OCPI" T0
INNER JOIN 
        "TARKON_PROD"."CPI1" T1 ON
	T0."DocEntry" = T1."DocEntry"
WHERE
	T1."LineStatus" = 'O'
	AND T1."Project" != ''
	AND T1."Project" != 'KO'
GROUP BY
	EXTRACT(YEAR
FROM
	T0."DocDueDate"),
	EXTRACT(MONTH
FROM
	T0."DocDueDate"),
	T1."Project"
),
BaseData AS (
SELECT
	COALESCE(OPCH.Rok,
	OCPI.Rok) AS Rok,
	COALESCE(OPCH.Miesiac,
	OCPI.Miesiac) AS Miesiac,
	COALESCE(OPCH.Projekty,
	OCPI.Projekty) AS Projekty,
	COALESCE(OPCH.Suma,
	0) + COALESCE(OCPI.Suma,
	0) AS Suma
FROM
	OPCHData OPCH
LEFT JOIN 
        OCPIData OCPI ON
	OPCH.Rok = OCPI.Rok
	AND OPCH.Miesiac = OCPI.Miesiac
	AND OPCH.Projekty = OCPI.Projekty
),
SumData AS (
SELECT
	Rok,
	Miesiac,
	Projekty,
	Suma,
	SUM(Suma) OVER (PARTITION BY Rok,
	Miesiac) AS SumaMiesiaca,
	ROW_NUMBER() OVER (PARTITION BY Rok,
	Miesiac
ORDER BY
	Projekty) AS RowNum,
	COUNT(*) OVER (PARTITION BY Rok,
	Miesiac) AS TotalRows
FROM
	BaseData
),
SumData1 AS (
SELECT
	Rok,
	Miesiac,
	Projekty,
	Suma,
	SumaMiesiaca,
	RowNum,
	CASE
		WHEN SumaMiesiaca <> 0 
        THEN ROUND((Suma / SumaMiesiaca) * 100, 2)
		ELSE 0
	END AS Procent,
	TotalRows
FROM
		SumData
),
SumData2 AS (
SELECT
	Rok,
	Miesiac,
	Projekty,
	Suma,
	SumaMiesiaca,
	RowNum,
	Procent,
	SUM(Procent) OVER (PARTITION BY Rok,
	Miesiac) AS SumaProcentow,
	TotalRows
FROM
		SumData1
),
Sumko AS (
SELECT
	EXTRACT(YEAR
FROM
	T0."DocDueDate") AS Rok,
	EXTRACT(MONTH
FROM
	T0."DocDueDate") AS Miesiac,
	SUM(T1."LineTotal") AS Suma
FROM
	"TARKON_PROD"."OPCH" T0
INNER JOIN 
        "TARKON_PROD"."PCH1" T1 ON
	T0."DocEntry" = T1."DocEntry"
WHERE
	T1."LineStatus" = 'O'
	AND (T1."Project" = ''
		OR T1."Project" = 'KO')
GROUP BY
	EXTRACT(YEAR
FROM
	T0."DocDueDate"),
	EXTRACT(MONTH
FROM
	T0."DocDueDate"),
	T1."Project"
),
Sumko1 AS (
SELECT
	EXTRACT(YEAR
FROM
	T0."DocDueDate") AS Rok,
	EXTRACT(MONTH
FROM
	T0."DocDueDate") AS Miesiac,
	SUM(T1."LineTotal") AS Suma
FROM
	"TARKON_PROD"."OCPI" T0
INNER JOIN 
        "TARKON_PROD"."CPI1" T1 ON
	T0."DocEntry" = T1."DocEntry"
WHERE
	T1."LineStatus" = 'O'
	AND (T1."Project" = ''
		OR T1."Project" = 'KO')
GROUP BY
	EXTRACT(YEAR
FROM
	T0."DocDueDate"),
	EXTRACT(MONTH
FROM
	T0."DocDueDate"),
	T1."Project"
),
Sumko3 AS (
SELECT
	COALESCE(OPCH.Rok,
	OCPI.Rok) AS Rok,
	COALESCE(OPCH.Miesiac,
	OCPI.Miesiac) AS Miesiac,
	COALESCE(OPCH.Suma,
	0) + COALESCE(OCPI.Suma,
	0) AS Suma
FROM
	Sumko OPCH
LEFT JOIN 
    Sumko1 OCPI 
ON
	OPCH.Rok = OCPI.Rok
	AND OPCH.Miesiac = OCPI.Miesiac
),
	Wyn AS (
SELECT
		w.Rok,
		w.Miesiac,
		w.Projekty,
		w.Suma,
		w.SumaMiesiaca,
		w.Procent,
		CASE
			WHEN w.SumaProcentow < 100
			AND w.RowNum = w.TotalRows THEN w.Procent + (100 - w.SumaProcentow)
			WHEN w.SumaProcentow >= 100
				AND w.RowNum = 1 THEN w.Procent
				ELSE w.Procent
			END AS SkorygowanyProcent,
				(CASE
					WHEN w.SumaProcentow < 100
					AND w.RowNum = w.TotalRows THEN (w.Procent + (100 - w.SumaProcentow)) / 100
					WHEN w.SumaProcentow >= 100
						AND w.RowNum = 1 THEN w.Procent / 100
						ELSE w.Procent / 100
					END) * s.Suma AS Mnoznik,
				s.Suma AS Sumako
		FROM
				SumData2 w
		LEFT JOIN Sumko3 s ON
				s.Rok = w.Rok
			AND s.Miesiac = w.Miesiac
)
SELECT
	Rok,
	Miesiac,
	Projekty,
	Suma,
	SumaMiesiaca,
	Procent,
	SkorygowanyProcent,
	ROUND(SUM(Mnoznik),2) AS koperproject,
	SUM(Sumako) AS sumako
FROM
	Wyn
GROUP BY
	Rok,
	Miesiac,
	Projekty,
	Suma,
	SumaMiesiaca,
	Procent,
	SkorygowanyProcent
ORDER BY
	Rok,
	Miesiac,
	Projekty
