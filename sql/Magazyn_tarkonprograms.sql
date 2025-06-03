SELECT
    m.PartID,
    MAX(m.[Date]) AS data,
    m.Person,
    m.Localization,
    (SELECT COUNT(l.PartID) from PartCheck.dbo.MagazynExtra l where l.PartID=m.PartID and l.Localization=m.Localization and l.Deleted=0) AS Ilosc,
    (SELECT COUNT(h.SheetName) from SNDBASE_PROD.dbo.StockArchive h where h.SheetName=sh1.SheetName) as zuzyte,
    s.Material,
    s.Thickness,
    s.[Length],
    s.Width
FROM
    PartCheck.dbo.MagazynExtra m
LEFT JOIN
    SNDBASE_PROD.dbo.Stock s ON m.PartID = s.SheetName COLLATE SQL_Latin1_General_CP1_CI_AS
LEFT JOIN
    SNDBASE_PROD.dbo.StockArchive sh1 on m.PartID=sh1.SheetName COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE m.Deleted = 0 and NOT EXISTS (
        SELECT 1
        FROM
            SNDBASE_PROD.dbo.StockArchive sh
        WHERE
            sh.SheetName = m.PartID COLLATE SQL_Latin1_General_CP1_CI_AS
            and sh1.Qty=0
    )
GROUP BY
    m.PartID, m.Person, m.Localization, s.Material, s.Thickness, s.[Length], s.Width, sh1.SheetName, m.Deleted
ORDER BY
    MAX(m.[Date]) DESC;