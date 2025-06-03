select
EXTRACT(YEAR
FROM
	cuce_date) AS Rok,
	EXTRACT(MONTH
FROM
	cuce_date) AS Miesiac,
	request_event.cr_number,
	sum(cuce_quantity) as czas,
	a.attr_values
from
	public.company_user_calendar_events
left join company_user_contracts on
	cuce_entity_type = 'contracts'
	and cuce_entity_fkey = cuc_id
left join company_contractors on
	cc_id = cuc_contractor_fkey
left join company_contractor_requests as request_contract on
	request_contract.cr_id = cuc_request_fkey
left join company_contractor_requests as request_event on
	request_event.cr_id = cuce_request_fkey
left join users on
	usr_id = cuce_user_fkey
left join user_ids on
	uid_user_fkey = usr_id
	and uid_deleted is false
	and uid_name = 'PESEL'
left join companies as cmp_contract on
	cmp_contract.cmp_id = cuc_company_fkey
left join companies as cmp_project on
	cmp_project.cmp_id = request_contract.cr_company_fkey
full join "attributes" a on
a.attr_entity_fkey=request_event.cr_id and a.attr_name = 'wagaproj'
where
	cuce_category in ( 'EMPLOYMENT', 'RATE')
	and cuce_deleted is false
	and cuce_category_detail_additional is not null
	and request_event.cr_number !='KO'
	group by request_event.cr_number,EXTRACT(YEAR from
	cuce_date),a.attr_values,
	EXTRACT(MONTH
FROM
	cuce_date)
	order by EXTRACT(YEAR
FROM
	cuce_date),
	EXTRACT(MONTH
FROM
	cuce_date),
	request_event.cr_number
	