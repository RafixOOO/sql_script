select
		ut_id as cuce_task,
		cr_id as cuce_request,
        ut_name AS cuce_category_detail_additional,
        cr_contractor_fkey,
        COALESCE(cps_id, 1110) AS cuce_position
    from company_contractor_requests AS request_event
    LEFT JOIN user_tasks ON request_event.cr_id = ut_entity_fkey
    left join company_contractor_positions on cps_contractor_fkey=cr_contractor_fkey and cps_deleted = false and cps_archival = false
    WHERE ut_deleted IS false
      and request_event.cr_number = 'PT956'
      and ut_entity_type = 'contractors-requests';
      
select
	usr_id as cuce_user,
	cuc_id as cuce_contract_fkey_and_cuce_entity_fkey,
	cuc_company_fkey as cuc_company_fkey
from user_ids
inner join users on uid_user_fkey=usr_id and uid_name='RFID' and uid_value='0002625059'
LEFT JOIN company_user_contracts 
    ON usr_id = cuc_user_fkey 
    AND cuc_deleted = false 
    AND (
        (cuc_end_date < CURRENT_DATE AND cuc_cancel_date < CURRENT_DATE) 
        OR 
        (cuc_end_date IS NULL AND cuc_cancel_date IS NULL)
        OR 
        (cuc_end_date IS NULL AND cuc_cancel_date < CURRENT_DATE)
    )
