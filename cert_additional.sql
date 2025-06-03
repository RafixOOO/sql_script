select
	u.usr_name,
	a.attr_values,
    uc.cert_standard,
    (regexp_matches(uc.cert_additional, '"method":"([0-9\\/]+)"'))[1] AS method_number,
    (regexp_matches(uc.cert_additional, '"connector_type":"([A-Za-z0-9]+)"'))[1] AS connector_type,
    (regexp_matches(uc.cert_additional, '"joint_type":"([A-Za-z0-9\\/]+)"'))[1] AS joint_type,
    (regexp_matches(uc.cert_additional, '"materials":"([A-Za-z0-9\., ]+)"'))[1] AS materials,
    (regexp_matches(uc.cert_additional, '"welding_position":"([A-Za-z0-9\/\-]+)"'))[1] AS welding_position
	, uc.cert_number
	,uc.cert_exhibitor
	,uc.cert_end_date
FROM
        user_certificates uc
    INNER JOIN
        users u ON uc.cert_user_fkey = u.usr_id
    inner join public.attributes a on u.usr_id=a.attr_entity_fkey
WHERE
    cert_additional LIKE '%{"welder":{"method"%' and 
    a.attr_name = 'Stempel spawacza'
ORDER BY
    cert_id desc;