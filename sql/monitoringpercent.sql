WITH DurationData AS (
    SELECT 
        j.StatusType,
        SUM(j.Duration) AS TotalDuration
    FROM utilizationtable u
    CROSS APPLY 
    OPENJSON(u.msg, '$.States') WITH (
        StatusType nvarchar(50) '$.Status.StatusType',
        Duration float '$.Duration'
    ) AS j
    WHERE DATEADD(hour, 2, u.[_internal_timestamp]) >= '2024-09-06'
      AND DATEADD(hour, 2, u.[_internal_timestamp]) < DATEADD(DAY, 1, '2024-09-06')
    GROUP BY j.StatusType
),
TotalDuration AS (
    SELECT 
        SUM(TotalDuration) AS GrandTotal
    FROM DurationData
)
SELECT 
    StatusType,
    TotalDuration,
    ROUND((TotalDuration * 100.0 / GrandTotal), 2) AS Percentage
FROM DurationData
CROSS JOIN TotalDuration
ORDER BY TotalDuration DESC;
