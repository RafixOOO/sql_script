WITH latest_wiza AS (
    SELECT DISTINCT ON (wiza_user_fkey) 
        wiza_user_fkey,
        wiza_date_end
    FROM public.user_wizas
    WHERE wiza_deleted IS FALSE 
        AND wiza_document_type = 'SAFETY_TRAINING'
    ORDER BY wiza_user_fkey, wiza_date_end DESC  -- Pobranie najnowszego szkolenia BHP
)
SELECT 
    cuc.cuc_user_fkey,
    u.usr_external_fkey,
    u.usr_name,
    cuc.cuc_number,
    cuc.cuc_company_fkey,
    cuc.cuc_type,
    cuc.cuc_start_date,
    cuc.cuc_end_date,
    cuc.cuc_position_name,
    w.wiza_number,
    w.wiza_date_start,
    w.wiza_date_end,
    w.wiza_document_type,
    w.wiza_company_fkey,
    CASE 
        WHEN lw.wiza_date_end IS NULL THEN 'NIE'  -- Brak jakiegokolwiek szkolenia
        WHEN lw.wiza_date_end >= CURRENT_DATE THEN 'TAK'  -- Ostatnie szkolenie jest aktualne
        ELSE 'NIE'  -- Ostatnie szkolenie jest przeterminowane
    END AS czy_ma_szkolenie
FROM public.company_user_contracts AS cuc
LEFT JOIN public.users AS u 
    ON u.usr_id = cuc.cuc_user_fkey 
    --AND cuc.cuc_user_fkey = 2714
LEFT JOIN public.user_wizas AS w 
    ON w.wiza_user_fkey = u.usr_id
    AND w.wiza_deleted IS FALSE 
    AND w.wiza_document_type = 'SAFETY_TRAINING'
LEFT JOIN latest_wiza AS lw 
    ON lw.wiza_user_fkey = u.usr_id  -- Dołączamy tylko najnowszą datę końca szkolenia
WHERE 
    cuc.cuc_deleted IS FALSE
    AND (cuc.cuc_end_date > CURRENT_DATE OR cuc.cuc_end_date IS NULL)
    AND (cuc.cuc_termination_date > CURRENT_DATE OR cuc.cuc_termination_date IS NULL)
    AND u.usr_name IS NOT NULL
ORDER BY 
    u.usr_external_fkey, 
    cuc.cuc_start_date, 
    w.wiza_date_end DESC;
