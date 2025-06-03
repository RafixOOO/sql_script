SELECT
    T1."Project" as "Projekt",
    T5."PrjName" as "Nazwa projektu",
    STRING_AGG(T2."DocNum", ',') as "Numer dokumentu",
    T0."ItemCode" as "Kod Indeksu",
    T4."ItemName" as "Nazwa Indeksu",
    SUM(T0."Quantity") as "Ilość",
    T1."unitMsr" as "Jednostka Miary",
    T0."BatchNum" as "Nr Partii",   
    T3."U_NRWYTOPU",
    T3."U_DLUGOSC",
    T3."U_SZEROKOSC",
    T3."U_GATUNEK",
    (SELECT DISTINCT STRING_AGG( CONCAT('file:', REPLACE(cast(T3_sub."U_CERTWYTOPU" as varchar), '\', '/')), ',')
     FROM "TARKON_PROD"."OBTN" T3_sub
     WHERE T3_sub."DistNumber" = T0."BatchNum" AND T3_sub."ItemCode" = T0."ItemCode") as "Certyfikat"
FROM
    "TARKON_PROD"."IBT1" T0
INNER JOIN
    "TARKON_PROD"."IGE1" T1 ON T0."BaseType" = T1."ObjType" AND T0."BaseEntry" = T1."DocEntry" AND T0."BaseLinNum" = T1."LineNum"
INNER JOIN
    "TARKON_PROD"."OIGE" T2 ON T1."DocEntry" = T2."DocEntry"  
INNER JOIN
    "TARKON_PROD"."OBTN" T3 ON T3."DistNumber" = T0."BatchNum" AND T3."ItemCode" = T0."ItemCode"
INNER JOIN
    "TARKON_PROD"."OITM" T4 ON T0."ItemCode" = T4."ItemCode"
INNER JOIN
    "TARKON_PROD"."OPRJ" T5 ON T1."Project" = T5."PrjCode"
    WHERE T3."U_CERTWYTOPU" IS NOT NULL 
GROUP BY
    T1."Project",
    T5."PrjName",
    T0."ItemCode",
    T4."ItemName",
    T1."unitMsr",
    T3."U_NRWYTOPU",
    T3."U_DLUGOSC",
    T3."U_SZEROKOSC",
    T3."U_GATUNEK",
    T0."BatchNum"
ORDER BY
    T1."Project";