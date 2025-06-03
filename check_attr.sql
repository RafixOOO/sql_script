SELECT
  u.usr_id,
  MAX(CASE WHEN ad.attrdef_name = 'Driver' THEN a.attr_values END) AS "Driver",
  MAX(CASE WHEN ad.attrdef_name = 'Driver 1' THEN a.attr_values END) AS "Driver 1",
  MAX(CASE WHEN ad.attrdef_name = 'Driver 2' THEN a.attr_values END) AS "Driver 2",
u.usr_id,
  MAX(CASE WHEN ad.attrdef_name = 'TYP projektu 1' THEN a.attr_values END) AS "TYP projektu 1",
  MAX(CASE WHEN ad.attrdef_name = 'TYP projektu' THEN a.attr_values END) AS "TYP projektu",
u.usr_id,
  MAX(CASE WHEN ad.attrdef_name = 'Qualification 1' THEN a.attr_values END) AS "Qualification 1",
  MAX(CASE WHEN ad.attrdef_name = 'Qualification' THEN a.attr_values END) AS "Qualification",
u.usr_id,
  MAX(CASE WHEN ad.attrdef_name = 'Availability 1' THEN a.attr_values END) AS "Availability 1",
  MAX(CASE WHEN ad.attrdef_name = 'Availability' THEN a.attr_values END) AS "Availability",
u.usr_id,
  MAX(CASE WHEN ad.attrdef_name = 'Pozycje spawania: 1' THEN a.attr_values END) AS "Pozycje spawania: 1",
  MAX(CASE WHEN ad.attrdef_name = 'Pozycje spawania:' THEN a.attr_values END) AS "Pozycje spawania:",
u.usr_id,
  MAX(CASE WHEN ad.attrdef_name = 'DODATKOWE UPRAWNIENIA lub UMIEJĘTNOŚĆ OBSŁUGI: 2' THEN a.attr_values END) AS "DODATKOWE UPRAWNIENIA lub UMIEJĘTNOŚĆ OBSŁUGI: 2",
  MAX(CASE WHEN ad.attrdef_name = 'DODATKOWE UPRAWNIENIA lub UMIEJĘTNOŚĆ OBSŁUGI: 1' THEN a.attr_values END) AS "DODATKOWE UPRAWNIENIA lub UMIEJĘTNOŚĆ OBSŁUGI: 1",
  MAX(CASE WHEN ad.attrdef_name = 'DODATKOWE UPRAWNIENIA lub UMIEJĘTNOŚĆ OBSŁUGI:' THEN a.attr_values END) AS "DODATKOWE UPRAWNIENIA lub UMIEJĘTNOŚĆ OBSŁUGI:",
u.usr_id,
  MAX(CASE WHEN ad.attrdef_name = 'wymiary ubrań 1' THEN a.attr_values END) AS "wymiary ubrań 1",
  MAX(CASE WHEN ad.attrdef_name = 'wymiary ubrań' THEN a.attr_values END) AS "wymiary ubrań",
u.usr_id,
  MAX(CASE WHEN ad.attrdef_name = 'Rodzaje doświadczenia w spawaniu/ montażu: 1' THEN a.attr_values END) AS "Rodzaje doświadczenia w spawaniu/ montażu: 1",
  MAX(CASE WHEN ad.attrdef_name = 'Rodzaje doświadczenia w spawaniu/ montażu:' THEN a.attr_values END) AS "Rodzaje doświadczenia w spawaniu/ montażu:",
u.usr_id,
  MAX(CASE WHEN ad.attrdef_name = 'UMIEJĘTNOŚĆ CZYTANIA I ANALIZOWANIA RYSUNKU TECHNICZNEGO 1' THEN a.attr_values END) AS "UMIEJĘTNOŚĆ CZYTANIA I ANALIZOWANIA RYSUNKU TECHNICZNEGO 1",
  MAX(CASE WHEN ad.attrdef_name = 'UMIEJĘTNOŚĆ CZYTANIA I ANALIZOWANIA RYSUNKU TECHNICZNEGO' THEN a.attr_values END) AS "UMIEJĘTNOŚĆ CZYTANIA I ANALIZOWANIA RYSUNKU TECHNICZNEGO"
FROM
  attributes a
JOIN
  attributes_def ad ON a.attr_attribute_def_fkey = ad.attrdef_id
LEFT JOIN
  users u ON a.attr_entity_fkey = u.usr_id
GROUP BY
  u.usr_id
ORDER BY
  u.usr_id;