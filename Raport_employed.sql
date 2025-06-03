WITH RECURSIVE YearlyContracts AS (
    -- Początkowy rok, czyli 2018
    SELECT 2025 AS year
    UNION ALL
    -- Rekursja: kolejny rok
    SELECT year + 1
    FROM YearlyContracts
    WHERE year < EXTRACT(YEAR FROM CURRENT_DATE) -- Zakładając, że chcesz zakres do 2029
),
RankedUsers AS (
    SELECT 
        u.usr_id,
        u.usr_name, 
         (SELECT a.cuc_position_name 
         FROM company_user_contracts a
         WHERE a.cuc_user_fkey = cuc.cuc_user_fkey
         AND a.cuc_deleted = false
         AND EXTRACT(YEAR FROM a.cuc_start_date) = yc.year
         ORDER BY a.cuc_start_date ASC 
         LIMIT 1
        ) AS first_contract_position,
        (SELECT cc1.cc_name 
         FROM company_user_contracts a
         INNER JOIN company_contractors cc1 ON a.cuc_contractor_fkey = cc1.cc_id
         WHERE a.cuc_user_fkey = cuc.cuc_user_fkey
         AND a.cuc_deleted = false
         AND EXTRACT(YEAR FROM a.cuc_start_date) = yc.year
         ORDER BY a.cuc_start_date ASC 
         LIMIT 1
        ) as first_contract_client_name, 
        up.up_birth_date,
        n.not_body,
        u.usr_state,
        at.attr_values,
        u.usr_external_fkey,
        -- Teraz zmiana: zamiast sprawdzać za pomocą MIN(cuc_start_date) dla całego przedziału, sprawdzamy dla każdego roku
        (SELECT MIN(cuc_start_date) 
 FROM company_user_contracts a 
 WHERE a.cuc_user_fkey = cuc.cuc_user_fkey
 AND a.cuc_deleted = false
 AND EXTRACT(YEAR FROM a.cuc_start_date) = yc.year  -- porównanie z danym rokiem
 LIMIT 1
) AS min_date,
        (SELECT CASE 
            WHEN a.cuc_cancel_date IS NOT NULL THEN a.cuc_cancel_date
            ELSE a.cuc_end_date
        END
        FROM company_user_contracts a
        WHERE a.cuc_user_fkey = cuc.cuc_user_fkey
          AND a.cuc_deleted = false
        ORDER BY a.cuc_end_date DESC
        LIMIT 1
        )  AS cuc_end_date,
        cuc.cuc_cancel_date,
        (SELECT c1.cmp_name 
         FROM company_user_contracts a
         INNER JOIN companies c1 ON a.cuc_company_fkey = c1.cmp_id
         WHERE a.cuc_user_fkey = cuc.cuc_user_fkey
         AND a.cuc_deleted = false
         AND EXTRACT(YEAR FROM a.cuc_start_date) = yc.year
         ORDER BY a.cuc_start_date ASC
         LIMIT 1
        ) AS first_contract_company_name,
        u2.usr_name AS Operator_name, 
        STRING_AGG(CONCAT(er.er_name, ' ', ROUND(er.er_amount, 2), ' ', er.er_currency), ', ') AS combined_column
    FROM users u
    LEFT JOIN user_personal up ON u.usr_id = up.up_user_fkey
    LEFT JOIN attributes at ON u.usr_id = at.attr_entity_fkey AND at.attr_name = 'Powód Zatrudnienia'
    INNER JOIN company_user_contracts cuc ON u.usr_id = cuc.cuc_user_fkey 
        AND cuc.cuc_deleted = false
    INNER JOIN companies c ON c.cmp_id = cuc.cuc_company_fkey
    INNER JOIN company_contractors cc ON cuc.cuc_contractor_fkey = cc.cc_id
    LEFT JOIN company_contractor_requests ccr ON ccr.cr_id = cuc.cuc_request_fkey
    LEFT JOIN company_accountants_map cam ON cam.cam_entity_fkey = ccr.cr_id 
        AND cam.cam_entity_type = 'contractors-requests'
    LEFT JOIN users u2 ON u2.usr_id = cam.cam_accountant_entity_fkey 
        AND cam.cam_accountant_entity_type = 'user'
    LEFT JOIN employee_rates er ON u.usr_id = er.er_user_fkey AND er.er_name = 'SH'  
        AND er.er_creation_time = (
            SELECT MAX(er_creation_time) 
            FROM employee_rates 
            WHERE er_user_fkey = u.usr_id
            AND er_name = 'SH'
            AND er_deleted = false
        )
    LEFT JOIN notes n ON cuc.cuc_id = n.not_entity_fkey 
        AND not_entity_type = 'contracts'
    CROSS JOIN YearlyContracts yc -- Dołączamy do zapytania dane z rekursywnej pętli
    WHERE u.usr_name != 'testowski test' 
        AND u.usr_state != 'Administracja'
        AND EXTRACT(YEAR FROM cuc.cuc_start_date) = yc.year -- warunek na dany rok
    GROUP BY u.usr_name, cc.cc_name, cuc.cuc_end_date, u2.usr_name, cuc.cuc_cancel_date, c.cmp_name, n.not_body, cuc.cuc_id, u.usr_state, u.usr_external_fkey, up.up_birth_date, at.attr_values, u.usr_id, yc.year
),
RankedContracts AS (
    SELECT 
        ru.usr_name,
        ru.min_date,
        MAX(
            CASE 
                WHEN cuc.cuc_cancel_date IS NOT NULL THEN cuc.cuc_cancel_date 
                ELSE cuc.cuc_end_date 
            END
        ) AS last_contract_date
    FROM RankedUsers ru
    INNER JOIN company_user_contracts cuc ON ru.usr_id = cuc.cuc_user_fkey
        AND cuc.cuc_deleted = false
        AND EXTRACT(YEAR FROM cuc.cuc_start_date) < EXTRACT(YEAR FROM ru.min_date)
    GROUP BY ru.usr_name,ru.min_date
)
SELECT distinct 
    ru.usr_state AS Status,
    ru.usr_external_fkey AS Zewnętrzne_ID,
    ru.usr_name AS Nazwisko_Imię, 
    ru.first_contract_position AS Stanowisko,
    ru.first_contract_client_name AS Klient,
    ru.up_birth_date AS Data_Urodzenia,
    ru.min_date AS Data_Pierwszego_Zatrudnienia,
    ru.first_contract_company_name AS Nazwa_Firmy, 
    ru.combined_column AS "B.u. Stawki",
    ru.cuc_end_date AS "N.u. Koniec",
    ru.attr_values AS Reason_of_Employment,
    CASE 
        WHEN rc.last_contract_date IS NULL THEN 'NEW'
        ELSE 'BACK'
    END AS "New/Back"
FROM RankedUsers ru
LEFT JOIN RankedContracts rc ON ru.usr_name = rc.usr_name and ru.min_date = rc.min_date
WHERE  (
        rc.last_contract_date IS NULL -- Nowy pracownik
        OR ru.min_date > rc.last_contract_date + INTERVAL '1 year' -- Powracający po przerwie > 1 rok
    )
ORDER BY ru.usr_name;
