SELECT 
    er.er_id,
    erc.erc_deleted,
    u.usr_name,
    CONCAT(er.er_name, ' ', ROUND(erc.erc_amount, 2), ' ', er.er_currency) AS combined_column
FROM users u
RIGHT JOIN employee_rates er 
    ON u.usr_id = er.er_user_fkey 
    AND (er.er_name = 'OH' OR er.er_name = 'ONH')
INNER JOIN employee_rate_calendars erc 
    ON erc.erc_entity_fkey = er.er_id
    AND erc.erc_date_from = (
        SELECT MAX(erc2.erc_date_from)
        FROM employee_rate_calendars erc2
        WHERE erc2.erc_entity_fkey = er.er_id
    ) and erc.erc_deleted is false and erc.erc_date_to > CURRENT_DATE
WHERE u.usr_state = 'Aktywny';
