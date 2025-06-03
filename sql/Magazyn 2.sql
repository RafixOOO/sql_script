SELECT liczba,"DocEntry", "BaseCard", "CardName", "ItemCode", "Dscription", "Quantity", "Price", "LineTotal", "SlpCode", "AcctCode", "AcctName", "DocDate", "Project", "LineStatus"
FROM (
    SELECT COUNT(T0."ItemCode") AS liczba, T0."DocEntry", T0."BaseCard", T3."CardName", T0."ItemCode", T0."Dscription", T0."Quantity", T0."Price", T0."LineTotal", T0."SlpCode", T0."AcctCode", T2."AcctName", T0."DocDate", T0."Project", T0."LineStatus",
           ROW_NUMBER() OVER (PARTITION BY T0."ItemCode" ORDER BY T0."DocDate" DESC) AS RowNum
    FROM TARKON_PROD.PCH1 T0
    LEFT JOIN TARKON_PROD.OCRD T3 ON T0."BaseCard" = T3."CardCode"  
    LEFT JOIN TARKON_PROD.OACT T2 ON T0."AcctCode" = T2."AcctCode"
    WHERE T0."LineStatus" = 'O'
    AND T0."ItemCode" LIKE 'STA%'
    AND CAST(SUBSTRING(T0."ItemCode", 4) AS INT) > 590
    GROUP BY T0."DocEntry", T0."BaseCard", T3."CardName", T0."ItemCode", T0."Dscription", T0."Quantity", T0."Price", T0."LineTotal", T0."SlpCode", T0."AcctCode", T2."AcctName", T0."DocDate", T0."Project", T0."LineStatus"
) AS RankedData
WHERE RowNum = 1;
