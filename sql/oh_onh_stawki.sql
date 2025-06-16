SELECT 
    erc.erc_id,
    erc.erc_deleted,
    u.usr_name,
    u.usr_state,
    CONCAT(er.er_name, ' ', ROUND(erc.erc_amount, 2), ' ', er.er_currency) AS combined_column,
    erc.erc_date_from
FROM users u
right JOIN employee_rates er 
    ON u.usr_id = er.er_user_fkey 
    AND (er.er_name = 'OH' OR er.er_name = 'ONH') and er.er_deleted is false
right JOIN employee_rate_calendars erc 
    ON erc.erc_employee_rate_fkey = er.er_id
    AND erc.erc_date_from = (
        SELECT MAX(erc2.erc_date_from)
        FROM employee_rate_calendars erc2
        WHERE erc2.erc_entity_fkey = er.er_id
    ) and 
    --erc.erc_deleted is false and
    erc.erc_date_to > CURRENT_DATE
WHERE 
--u.usr_state = 'Aktywny'
er.er_id is not null and
u.usr_name is not null
