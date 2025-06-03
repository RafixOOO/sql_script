WITH NumerowaneUmowy AS (
    SELECT
        num.Imie,
        num.Nazwisko,
        prac.PESEL,
        prac.Plec,
        prac.Data_urodzenia,
        s.Nazwa as stanowisko,
        d.Nazwa as dzial,
        'TARKON' as firma,
        u.Data_zawarcia_umowy as umpracaod,
        u.Data_zakonczenia_pracy as umpracado,
        u.Etat_licznik as umpracczas,
        u.X_01Wyliczony  as umprackwo,
        u2.Data_zawarcia_umowy as umzelcod,
        u2.Data_zakonczenia_pracy as umzelcdo,
        u2.Kwota as umzleckwo,
        u3.Data_zawarcia_umowy as umdzielod,
        u3.Data_zakonczenia_pracy as umdzieldo,
        u3.Kwota as umdzielkwo,
        ROW_NUMBER() OVER (PARTITION BY num.X_IPracownik ORDER BY u.Data_zakonczenia_pracy DESC) AS rn
    FROM
        R2P_platnik10_PROD_dane_1.dbo.NPOZLIST num
        INNER JOIN R2P_platnik10_PROD_dane_1.dbo.PRACDANE prac ON (num.X_IPracownik = prac.X_IPracownik)
        INNER JOIN R2P_platnik10_PROD_dane_1.dbo.DZIAL d ON (num.X_IDzial = d.X_I)
        INNER JOIN R2P_platnik10_PROD_dane_1.dbo.PRACOWNK p ON (num.X_ILista = p.X_I)
        INNER JOIN R2P_platnik10_PROD_dane_1.dbo.STANOW s ON (p.X_IStanowisko = s.X_I)
        LEFT JOIN R2P_platnik10_PROD_dane_1.dbo.UMPRACA u ON (p.X_I = u.X_IPracownik)
        LEFT JOIN R2P_platnik10_PROD_dane_1.dbo.UMZLEC u2 ON (p.X_I = u2.X_IPracownik)
        LEFT JOIN R2P_platnik10_PROD_dane_1.dbo.UMDZIELO u3 ON (p.X_I = u3.X_IPracownik)
)
SELECT
    Imie,
    Nazwisko,
    PESEL,
    Plec,
    Data_urodzenia,
    stanowisko,
    dzial,
    firma,
    umpracaod,
    umpracado,
    umpracczas,
    umprackwo,
    umzelcod,
    umzelcdo,
    umzleckwo,
    umdzielod,
    umdzieldo,
    umdzielkwo
FROM NumerowaneUmowy
WHERE rn = 1