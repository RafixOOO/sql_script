SELECT 
    CAST(DATE_PART('year', cra_creation_time) AS VARCHAR) || '-' || 
    LPAD(CAST(DATE_PART('month', cra_creation_time) AS VARCHAR), 2, '0') AS month,
    COUNT(cra.cra_id) AS application_count,
    COUNT(DISTINCT u.usr_id) AS candidant,
    COALESCE(cra.cra_source, u.usr_user_source) AS source
FROM 
    company_recruitment_applications cra
    full JOIN users u ON u.usr_id = cra.cra_user_fkey
    where usr_state='Kandydat' and usr_source!='IMPORT'
GROUP BY 
    DATE_PART('year', cra_creation_time), 
    DATE_PART('month', cra_creation_time), 
    COALESCE(cra.cra_source, u.usr_user_source)
ORDER BY 
    DATE_PART('year', cra_creation_time), 
    DATE_PART('month', cra_creation_time);