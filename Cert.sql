SELECT
    usr_name,
    cr_number,
    cert_number,
    file_url
FROM (
    SELECT
        u.usr_name,
        request_event.cr_number,
        uc.cert_number,
        CONCAT('https://hrappka.budhrd.eu/files/get/f_hash/', f.f_hash, '/h/', c.cmp_hash) AS file_url,
        ROW_NUMBER() OVER(PARTITION BY u.usr_name, uc.cert_number ORDER BY f.f_hash) AS row_num
    FROM
        files f
    INNER JOIN
        companies c ON f.f_company_fkey = c.cmp_id
    INNER JOIN
        user_certificates uc ON f.f_entity_fkey = uc.cert_id
    INNER JOIN
        users u ON f.f_entity_main_fkey = u.usr_id
    INNER JOIN
        company_user_calendar_events cuce ON cuce.cuce_user_fkey = f.f_entity_main_fkey
    INNER JOIN
        company_contractor_requests request_event ON request_event.cr_id = cuce.cuce_request_fkey
    WHERE
        f.f_entity_type = 'user-certificates'
        AND f.f_deleted = false
        AND uc.cert_deleted = false
        AND uc.cert_number = '053022KTW22'
        AND uc.cert_end_date > current_date
        AND cuce.cuce_deleted = false
        AND uc.cert_type = 'CERTIFICATE_TYPE_WELDER'
) AS subquery
WHERE
    row_num = 1
GROUP BY
    usr_name,
    cr_number,
    cert_number,
    file_url;