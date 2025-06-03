select distinct usr_external_fkey as id, usr_name as imie_nazwisko,cui_price as potrącenie,EXTRACT(YEAR FROM cui_settlement_date) AS rok,
  EXTRACT(MONTH FROM cui_settlement_date) AS miesiac from users 
inner join company_user_items on cui_user_fkey=usr_id and cui_name like '%wynagrodzenie chorobowe%'
where usr_state not in ('Kandydat','Zwolniony') order by EXTRACT(YEAR FROM cui_settlement_date), EXTRACT(MONTH FROM cui_settlement_date)