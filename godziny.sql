SELECT
usr_name,
cuce_category,
cuce_date,
cuce_quantity,
CASE WHEN ut_name IS NOT NULL THEN ut_name ELSE cuce_category_detail_additional END AS czynnosc,
request_event.cr_number,
cuce_source
FROM public.company_user_calendar_events
LEFT JOIN company_user_contracts ON cuce_entity_type = 'contracts' AND cuce_entity_fkey = cuc_id
LEFT JOIN company_contractors ON cc_id = cuc_contractor_fkey
LEFT JOIN company_contractor_requests AS request_contract ON request_contract.cr_id = cuc_request_fkey
LEFT JOIN company_contractor_requests AS request_event ON request_event.cr_id = cuce_request_fkey
LEFT JOIN users ON usr_id = cuc_user_fkey
LEFT JOIN user_ids ON uid_user_fkey = usr_id AND uid_deleted IS FALSE AND uid_name = 'PESEL'
LEFT JOIN companies AS cmp_contract ON cmp_contract.cmp_id = cuc_company_fkey
LEFT JOIN companies AS cmp_project ON cmp_project.cmp_id = request_contract.cr_company_fkey
LEFT JOIN user_tasks ON cuce_task_fkey = ut_id
WHERE cuce_category IN ('RATE')
--AND cuce_date >= '2023-11-01'
AND cuce_deleted IS FALSE
AND cuce_entity_type = 'contracts'
AND cuc_deleted IS FALSE
AND cuce_source IN ('INTERNAL_WORKER', 'WIDGET_RCP')
ORDER BY cuce_date DESC;
