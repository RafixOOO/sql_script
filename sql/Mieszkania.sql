WITH date_series AS (
    -- Generowanie dni w danym roku
    SELECT generate_series(
        '2023-01-01'::date, 
        '2025-01-31'::date, 
        interval '1 day'
    )::date AS event_date
),
month_range AS (
    -- Liczba dni w każdym miesiącu
    SELECT
        EXTRACT(YEAR FROM event_date) AS year,
        EXTRACT(MONTH FROM event_date) AS month,
        COUNT(*) AS total_days
    FROM generate_series(
        '2023-01-01'::date,
        '2025-01-31'::date,
        interval '1 day'
    ) AS g(event_date)
    GROUP BY EXTRACT(YEAR FROM event_date), EXTRACT(MONTH FROM event_date)
),
periods_with_availability AS (
    -- Połączenie okresów wynajmu i dostępności mieszkań
    SELECT
        cap.aptp_entity_fkey,
        cap.aptp_date_from,
        cap.aptp_date_to,
        cap.aptp_count_places,
        aptav.aptav_date_available_from,
        aptav.aptav_date_available_to
    FROM company_apartments_places cap
    LEFT JOIN company_apartments_availability aptav
        ON cap.aptp_entity_fkey = aptav.aptav_apartment_fkey
        AND aptav.aptav_deleted = false
    WHERE cap.aptp_deleted = false
),
calculated_dates AS (
    -- Określenie dat dostępności w kontekście każdego dnia, uwzględniając zarówno okres wynajmu, jak i dostępność
    SELECT
        p.aptp_entity_fkey,
        p.aptp_count_places,
        LEAST(p.aptp_date_to, COALESCE(p.aptav_date_available_to, p.aptp_date_to)) AS valid_end_date,
        GREATEST(p.aptp_date_from, COALESCE(p.aptav_date_available_from, p.aptp_date_from)) AS valid_start_date,
        date_series.event_date
    FROM date_series
    CROSS JOIN periods_with_availability p
    WHERE 
        date_series.event_date BETWEEN p.aptp_date_from AND COALESCE(p.aptp_date_to, date_series.event_date)
        AND date_series.event_date BETWEEN p.aptav_date_available_from AND COALESCE(p.aptav_date_available_to, date_series.event_date)
),
monthly_beds AS (
    -- Liczba dostępnych łóżek w każdym miesiącu
    SELECT 
        aptp_entity_fkey, 
        TO_CHAR(event_date, 'YYYY-MM') AS year_month,
        SUM(aptp_count_places) AS total_beds
    FROM calculated_dates
    GROUP BY aptp_entity_fkey, TO_CHAR(event_date, 'YYYY-MM')
),
daily_occupied_beds AS (
    -- Liczba zajętych łóżek w danym miesiącu
   SELECT 
    c.cuce_id,
    a.apt_id AS aptp_id,
    COALESCE(SUM(CASE WHEN d.event_date BETWEEN c.cuce_date AND COALESCE(c.cuce_date_to, CURRENT_DATE) THEN 1 ELSE 0 END) 
    OVER (PARTITION BY a.apt_id, TO_CHAR(d.event_date, 'YYYY-MM') ORDER BY d.event_date), 0) AS occupied_bed, 
    TO_CHAR(d.event_date, 'YYYY-MM') AS year_month  -- Wyświetlanie dokładnego dnia
FROM 
    date_series d
LEFT JOIN public.company_user_calendar_events c
    ON d.event_date BETWEEN c.cuce_date AND COALESCE(c.cuce_date_to, CURRENT_DATE)
LEFT JOIN company_apartments a
    ON a.apt_id = c.cuce_entity_fkey 
    AND a.apt_deleted IS FALSE
LEFT JOIN company_apartments_places cap
    ON a.apt_id = cap.aptp_entity_fkey
    AND cap.aptp_deleted IS FALSE
JOIN month_range mr
    ON EXTRACT(YEAR FROM d.event_date) = mr.year
    AND EXTRACT(MONTH FROM d.event_date) = mr.month
WHERE 
    c.cuce_category = 'ACCOMMODATION'
    and cuce_realization_state = 'REALIZED'
    AND c.cuce_deleted IS FALSE  
    AND (
        -- Sprawdza, czy mieszkanie było dostępne w danym miesiącu
        cap.aptp_date_from <= date_trunc('month', d.event_date) + interval '1 month' - interval '1 day'
        AND (cap.aptp_date_to IS NULL OR cap.aptp_date_to >= date_trunc('month', d.event_date))
    )
GROUP BY 
    a.apt_id, TO_CHAR(d.event_date, 'YYYY-MM'),d.event_date,c.cuce_date,c.cuce_date_to,c.cuce_id
)
SELECT
    a.apt_id, 
    a.apt_name, 
    a.apt_number,
    a.apt_state,
    TO_CHAR(p.aptav_date_available_from, 'YYYY-MM-DD') AS data_dostepnosci_od,
    TO_CHAR(p.aptav_date_available_to, 'YYYY-MM-DD') AS data_dostepnosci_do,
    mb.year_month,
    COALESCE(mb.total_beds, 0) AS liczba_lozek_na_miesiac, 
    max(COALESCE(ob.occupied_bed, 0)) AS liczba_zajetych_lozek_na_miesiac
FROM 
    company_apartments a
LEFT JOIN monthly_beds mb 
    ON a.apt_id = mb.aptp_entity_fkey
LEFT JOIN daily_occupied_beds ob 
    ON a.apt_id = ob.aptp_id 
    AND mb.year_month = ob.year_month
LEFT JOIN periods_with_availability p 
    ON p.aptp_entity_fkey = a.apt_id
    AND TO_CHAR(p.aptav_date_available_from, 'YYYY-MM') <= mb.year_month  -- dostępność zaczyna się przed lub w tym miesiącu
    AND (p.aptav_date_available_to IS NULL OR TO_CHAR(p.aptav_date_available_to, 'YYYY-MM') >= mb.year_month)  -- dostępność kończy się po lub w tym miesiącu
WHERE 
    a.apt_deleted IS false
    and a.apt_number = 'M074'
    and a.apt_state = 'Aktywne'
    group by  a.apt_id, 
    a.apt_name, 
    a.apt_number,
    a.apt_state,
    TO_CHAR(p.aptav_date_available_from, 'YYYY-MM-DD'),
    TO_CHAR(p.aptav_date_available_to, 'YYYY-MM-DD'),
    mb.year_month,
    COALESCE(mb.total_beds, 0)
ORDER BY 
    mb.year_month;

