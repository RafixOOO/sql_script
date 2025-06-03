SELECT Projekt, count(Pozycja) ,Id_import
FROM PartCheck.dbo.Parts
group by Projekt, Id_import
order by Projekt desc;