WITH DurationOrdered AS (
    SELECT 
        u.[_internal_timestamp],
        j.StatusType,
        j.Duration,
        ROW_NUMBER() OVER (PARTITION BY u.[_internal_timestamp] ORDER BY j.Duration) AS RowNum
    FROM utilizationtable u
    CROSS APPLY 
    OPENJSON(u.msg, '$.States') WITH (
        StatusType nvarchar(50) '$.Status.StatusType',
        Duration float '$.Duration'
    ) AS j
),
AccumulatedTimes AS (
    SELECT 
        _internal_timestamp,
        StatusType,
        Duration,
        RowNum,
        DATEADD(SECOND, SUM(Duration) OVER (PARTITION BY _internal_timestamp ORDER BY RowNum ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), _internal_timestamp) AS AdjustedTimestamp
    FROM DurationOrdered
),
PreviousTimes AS (
    SELECT 
        _internal_timestamp,
        StatusType,
        Duration,
        -- First, add 2 hours using DATEADD, then apply the FORMAT function
        FORMAT(LAG(DATEADD(HOUR, 2, AdjustedTimestamp), 1, DATEADD(HOUR, 2, _internal_timestamp)) 
               OVER (PARTITION BY _internal_timestamp ORDER BY RowNum), 'yyyy-MM-ddTHH:mm:ss') AS PreviousAdjustedTimestamp,
        FORMAT(DATEADD(HOUR, 2, AdjustedTimestamp), 'yyyy-MM-ddTHH:mm:ss') AS AdjustedTimestamp
    FROM AccumulatedTimes
)
SELECT 
    PreviousAdjustedTimestamp,
    StatusType,
    AdjustedTimestamp
FROM PreviousTimes
WHERE PreviousAdjustedTimestamp >= '2024-09-09'
    AND PreviousAdjustedTimestamp < DATEADD(DAY, 1, '2024-09-09')
ORDER BY PreviousAdjustedTimestamp ASC;
