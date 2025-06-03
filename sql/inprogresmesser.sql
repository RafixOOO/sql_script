SELECT 
    `_internal_timestamp` as time,
    LEFT(
        SUBSTRING(
            JSON_UNQUOTE(JSON_EXTRACT(msg, '$.Filename')), 
            LENGTH(JSON_UNQUOTE(JSON_EXTRACT(msg, '$.Filename'))) - LOCATE('/', REVERSE(JSON_UNQUOTE(JSON_EXTRACT(msg, '$.Filename')))) + 2, 
            LENGTH(JSON_UNQUOTE(JSON_EXTRACT(msg, '$.Filename')))
        ), 
        LENGTH(SUBSTRING(
            JSON_UNQUOTE(JSON_EXTRACT(msg, '$.Filename')), 
            LENGTH(JSON_UNQUOTE(JSON_EXTRACT(msg, '$.Filename'))) - LOCATE('/', REVERSE(JSON_UNQUOTE(JSON_EXTRACT(msg, '$.Filename')))) + 2, 
            LENGTH(JSON_UNQUOTE(JSON_EXTRACT(msg, '$.Filename')))
        )) - 4
    ) AS PartProgramName
FROM 
    db_eventpartprogramtable
ORDER BY 
    id DESC
LIMIT 1;
