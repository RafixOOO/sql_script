SELECT
    cci_id,
    cci_number AS numer_zewnetrzny,
    cci_issue_date AS data_wystawienia,
    cci_deadline AS termin_płatności,
    cci_seller_name AS nazwa_dostawcy,
    cci_seller_nip AS NIP_dostawcy,
    cta_amount AS koszt_w_proj,
    cci_net AS wartosc_netto_faktury,
    cci_gross AS wartosc_brutto_faktury,
    cci_vat AS VATzfktury,
    cci_currency AS waluta,
    cci_exchange_rate,
    cta_creation_time,
    cta_last_update_time,
    -- Nowa kolumna przeliczająca wartość cta_amount na PLN, jeśli waluta jest inna niż PLN
    CASE 
        WHEN cci_currency != 'PLN' THEN cta_amount * cci_exchange_rate
        ELSE cta_amount
    END AS netto_w_PLN,
    cci_system_state AS status,
    cci_registry_number AS numer_z_rejestru,
    cr_number AS Projekt,
    cr_name AS nazwa_proj,
    proj.cr_operator_fkey, -- Dodanie klucza cr_operator_fkey
    CONCAT(REPLACE(cast(f_path AS text), '/var/www/hrappka/public', 'http://hrappka.budhrd.eu'), f_name) AS Link_url,
    u2.usr_email as email_operator,
    u2.usr_name AS Operator_name
FROM public.cost_allocation
INNER JOIN public.company_contractor_invoices fak ON cci_id = cta_invoice_fkey
INNER JOIN public.company_contractor_requests proj ON cr_id = cta_project_fkey
inner join public.company_accountants_map cam on cam.cam_entity_fkey = proj.cr_id and cam.cam_entity_type ='contractors-requests'
LEFT JOIN public.users u2 ON u2.usr_id = cam.cam_accountant_entity_fkey and cam.cam_accountant_entity_type = 'user' -- Połączenie dla Imie_nazwisko_opiekuna_proj
LEFT JOIN public.files files ON f_entity_fkey = cta_invoice_fkey
WHERE files.f_deleted IS FALSE 
  AND f_entity_type = 'invoice-printout' 
  AND cta_deleted IS FALSE 
  AND (cta_creation_time > '2025-01-09 11:00:00' or cta_last_update_time > '2025-01-09 11:00:00') and cam.cam_deleted = false
ORDER BY cci_id DESC;