WITH RankedUsers AS (
    SELECT 
        u.usr_name, 
        cuc.cuc_position_name, 
        cc.cc_name, 
        n.not_body,
        (SELECT MIN(cuc_start_date) 
         FROM company_user_contracts a 
         WHERE a.cuc_user_fkey = cuc.cuc_user_fkey
         AND a.cuc_deleted = false
        ) AS min_date,
        CASE 
  WHEN cuc.cuc_cancel_date IS NOT NULL
    THEN cuc.cuc_cancel_date
  ELSE cuc.cuc_end_date
END AS cuc_end_date, -- Jeżeli cuc_cancel_date nie jest NULL, wyświetlamy ją zamiast cuc_end_date
        cuc.cuc_cancel_date,
        c.cmp_name,
        u2.usr_name AS Operator_name, 
        STRING_AGG(CONCAT(er.er_name, ' ', ROUND(er.er_amount, 2), ' ', er.er_currency), ', ') AS combined_column,
        ROW_NUMBER() OVER (
            PARTITION BY u.usr_name 
            ORDER BY 
                CASE 
                    WHEN cuc.cuc_cancel_date IS NOT NULL THEN 1 
                    ELSE 2 
                END, 
                cuc.cuc_end_date DESC
        ) AS row_num,
        at.attr_values
    FROM users u
    INNER JOIN company_user_contracts cuc ON u.usr_id = cuc.cuc_user_fkey and cuc.cuc_deleted = false
    INNER JOIN companies c ON c.cmp_id = cuc.cuc_company_fkey
    INNER JOIN company_contractors cc ON cuc.cuc_contractor_fkey = cc.cc_id
    left JOIN company_contractor_requests ccr ON ccr.cr_id = cuc.cuc_request_fkey
    LEFT JOIN company_accountants_map cam ON cam.cam_entity_fkey = ccr.cr_id AND cam.cam_entity_type = 'contractors-requests' and cam.cam_deleted is false
    LEFT JOIN users u2 ON u2.usr_id = cam.cam_accountant_entity_fkey AND cam.cam_accountant_entity_type = 'user' and u2.usr_state!='Zwolniony'
    LEFT JOIN employee_rates er ON u.usr_id = er.er_user_fkey AND er.er_name = 'SH'  -- Tylko SH
AND er.er_creation_time = (
    SELECT MAX(er_creation_time) 
    FROM employee_rates 
    WHERE er_user_fkey = u.usr_id
    AND er_name = 'SH'
    AND er_deleted IS FALSE
)
    left join notes n on cuc.cuc_id=n.not_entity_fkey and not_entity_type='contracts'
    LEFT JOIN attributes at ON u.usr_id = at.attr_entity_fkey AND at.attr_name = 'Powód zwolnienia /odejścia'
    WHERE (u.usr_state = 'Zwolniony' OR u.usr_state = 'Niezatrudniać') and u.usr_name!='testowski test'
    AND (cuc.cuc_end_date = (
        SELECT cuc_end_date
        FROM company_user_contracts cuc_sub
        INNER JOIN company_contractors cc_sub ON cuc_sub.cuc_contractor_fkey = cc_sub.cc_id
        WHERE cuc_sub.cuc_user_fkey = u.usr_id
        AND (cuc_sub.cuc_end_date >= '2025-01-01' or cuc_sub.cuc_cancel_date >= '2025-01-01')
        AND (cuc_sub.cuc_end_date <= current_date or cuc_sub.cuc_cancel_date <= current_date) 
        AND cc_sub.cc_name != 'AA_Oczekuje'
        ORDER BY cuc_sub.cuc_last_update_time DESC
    LIMIT 1
    )OR NOT EXISTS (  -- Jeżeli brak innych umów, wybieramy umowę AA_Oczekuje
            SELECT 1
            FROM company_user_contracts cuc_sub
            WHERE cuc_sub.cuc_user_fkey = u.usr_id
              AND cuc_sub.cuc_end_date >= '2025-01-01'
              AND cuc_sub.cuc_contractor_fkey != cuc.cuc_contractor_fkey  -- Unikamy wzięcia tej samej umowy
        ))
    AND cuc.cuc_end_date >= '2025-01-01' 
    AND (
        cc.cc_name != 'AA_Oczekuje'
        OR (cc.cc_name = 'AA_Oczekuje' AND NOT EXISTS (
            SELECT 1
            FROM company_user_contracts cuc_sub
            WHERE cuc_sub.cuc_user_fkey = u.usr_id
              AND cuc_sub.cuc_end_date >= '2025-01-01'
              AND cuc_sub.cuc_contractor_fkey != cc.cc_id
        ))
    )
    GROUP BY u.usr_name, cuc.cuc_position_name, cc.cc_name, cuc.cuc_end_date, u2.usr_name, cuc.cuc_cancel_date, c.cmp_name,n.not_body,cuc.cuc_id,at.attr_values
)
SELECT 
    usr_name,
    cuc_position_name,
    cc_name,
    attr_values,
    REPLACE(REPLACE(not_body, '<div>', ''), '</div>', '') AS cleaned_body,
    min_date,
    cuc_end_date, -- Teraz będzie wyświetlana wartość cuc_cancel_date, jeżeli nie jest null
    cmp_name,
    Operator_name,
    combined_column,
  CASE
    WHEN EXTRACT(YEAR FROM min_date) = EXTRACT(YEAR FROM cuc_end_date) THEN 'new'
    ELSE 'old'
END AS contract_status
FROM RankedUsers
WHERE row_num = 1
ORDER BY usr_name;
