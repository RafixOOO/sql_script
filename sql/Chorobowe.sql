SELECT    'TP'  as firma
      , poz.[WW]
	   ,poz.[X_I_SYS]
	   ,B.Nazwa
	  ,num.Imie
	  ,num.Nazwisko
	  ,num.Identyfikator as RCP
	    ,prac.PESEL
	  ,list.Kartoteka_z_miesiaca
	  ,list.Kartoteka_z_roku
	    ,CONCAT(list.Kartoteka_z_roku, list.Kartoteka_z_miesiaca) AS Okres
	  ,list.Opis
,list.Numer collate Polish_CI_AS as Numer
,list.X_IRejestr
,rej.[Nazwa] as rejnazwa
	,def.[Nazwa]	as defnazwa  
	,list.Data_wplaty
  FROM [R2P_platnik10_PROD_dane_8].[dbo].[POZLSYS] poz
  inner join R2P_platnik10_PROD_dane_8.dbo.NPOZLIST num on (poz.X_I_POZL = num.X_I)
--  INNER JOIN R2P_platnik10_PROD_bin.dbo.SKLADNIK s ON poz.X_I_SKL = s.X_I
  INNER JOIN R2P_platnik10_PROD_dane_8.dbo.LISTA list ON num.X_ILista = list.X_I
left join R2P_platnik10_PROD_dane_8.dbo.PRACDANE prac on (num.X_IPracownik = prac.X_IPracownik)
	INNER JOIN R2P_platnik10_PROD_bin.dbo.Polasys B ON poz.X_I_SYS = B.X_I
INNER JOIN R2P_platnik10_PROD_dane_8.dbo.REJESTR rej ON list.X_IRejestr = rej.X_I
  INNER JOIN R2P_platnik10_PROD_bin.dbo.DEFLIST def ON list.[X_IDefList] = def.X_I
where poz.[X_I_SYS]=44 
union all
SELECT    'TN'  as firma
      , poz.[WW]
	   ,poz.[X_I_SYS]
	   ,B.Nazwa
	  ,num.Imie
	  ,num.Nazwisko
	  ,num.Identyfikator as RCP
	    ,prac.PESEL
	  ,list.Kartoteka_z_miesiaca
	  ,list.Kartoteka_z_roku
	    ,CONCAT(list.Kartoteka_z_roku, list.Kartoteka_z_miesiaca) AS Okres
	  ,list.Opis
,list.Numer collate Polish_CI_AS as Numer
,list.X_IRejestr
,rej.[Nazwa] as rejnazwa
	,def.[Nazwa]	as defnazwa  
,list.Data_wplaty
  FROM [R2P_platnik10_PROD_dane_1].[dbo].[POZLSYS] poz
  inner join R2P_platnik10_PROD_dane_1.dbo.NPOZLIST num on (poz.X_I_POZL = num.X_I)
--  INNER JOIN R2P_platnik10_PROD_bin.dbo.SKLADNIK s ON poz.X_I_SKL = s.X_I
  INNER JOIN R2P_platnik10_PROD_dane_1.dbo.LISTA list ON num.X_ILista = list.X_I
left join R2P_platnik10_PROD_dane_1.dbo.PRACDANE prac on (num.X_IPracownik = prac.X_IPracownik)
	INNER JOIN R2P_platnik10_PROD_bin.dbo.Polasys B ON poz.X_I_SYS = B.X_I
INNER JOIN R2P_platnik10_PROD_dane_1.dbo.REJESTR rej ON list.X_IRejestr = rej.X_I
  INNER JOIN R2P_platnik10_PROD_bin.dbo.DEFLIST def ON list.[X_IDefList] = def.X_I
where poz.[X_I_SYS]=44 
union all
SELECT    'WL'  as firma
      , poz.[WW]
	   ,poz.[X_I_SYS]
	   ,B.Nazwa
	  ,num.Imie
	  ,num.Nazwisko
	  ,num.Identyfikator as RCP
	    ,prac.PESEL
	  ,list.Kartoteka_z_miesiaca
	  ,list.Kartoteka_z_roku
	    ,CONCAT(list.Kartoteka_z_roku, list.Kartoteka_z_miesiaca) AS Okres
	  ,list.Opis
,list.Numer collate Polish_CI_AS as Numer
,list.X_IRejestr
,rej.[Nazwa] as rejnazwa
	,def.[Nazwa]	as defnazwa  
,list.Data_wplaty
  FROM [R2P_platnik10_PROD_dane_7].[dbo].[POZLSYS] poz
  inner join R2P_platnik10_PROD_dane_7.dbo.NPOZLIST num on (poz.X_I_POZL = num.X_I)
--  INNER JOIN R2P_platnik10_PROD_bin.dbo.SKLADNIK s ON poz.X_I_SKL = s.X_I
  INNER JOIN R2P_platnik10_PROD_dane_7.dbo.LISTA list ON num.X_ILista = list.X_I
left join R2P_platnik10_PROD_dane_7.dbo.PRACDANE prac on (num.X_IPracownik = prac.X_IPracownik)
	INNER JOIN R2P_platnik10_PROD_bin.dbo.Polasys B ON poz.X_I_SYS = B.X_I
INNER JOIN R2P_platnik10_PROD_dane_7.dbo.REJESTR rej ON list.X_IRejestr = rej.X_I
  INNER JOIN R2P_platnik10_PROD_bin.dbo.DEFLIST def ON list.[X_IDefList] = def.X_I
where poz.[X_I_SYS]=44