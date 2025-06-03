SELECT
    u.usr_name AS imie_nazwisko,
    ui.uid_value AS PESEL,
    up.up_birth_date AS Data_urodzenia,
    CASE
        WHEN 
            SUBSTRING(ui.uid_value, 1, 2) || '-' || 
            SUBSTRING(ui.uid_value, 3, 2) || '-' || 
            SUBSTRING(ui.uid_value, 5, 2) = 
            TO_CHAR(up.up_birth_date, 'YY-MM-DD')
        THEN 'Zgadza się'
        ELSE 'Nie zgadza się'
    END AS Zgodność
FROM user_ids ui
INNER JOIN users u ON ui.uid_user_fkey = u.usr_id
INNER JOIN user_personal up ON up.up_user_fkey = u.usr_id
WHERE ui.uid_name = 'PESEL';


