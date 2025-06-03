SELECT 
j2.id,
    LEFT(
        SUBSTRING(
            JSON_VALUE(j2.msg, '$.PartProgramName'), 
            LEN(JSON_VALUE(j2.msg, '$.PartProgramName')) - CHARINDEX('/', REVERSE(JSON_VALUE(j2.msg, '$.PartProgramName'))) + 2, 
            LEN(JSON_VALUE(j2.msg, '$.PartProgramName'))
        ), 
        LEN(SUBSTRING(
            JSON_VALUE(j2.msg, '$.PartProgramName'), 
            LEN(JSON_VALUE(j2.msg, '$.PartProgramName')) - CHARINDEX('/', REVERSE(JSON_VALUE(j2.msg, '$.PartProgramName'))) + 2, 
            LEN(JSON_VALUE(j2.msg, '$.PartProgramName'))
        )) - 4
    ) AS PartProgramName,
    DATEADD(hour, 2, j2.[_internal_timestamp]) AS Starttime,
        DATEADD(hour, 2, j2.[_internal_endtime]) AS Endtime,
    -- Czas trwania dla każdego typu stanu
    ISNULL(
        CONVERT(varchar, DATEADD(SECOND, SUM(CASE WHEN j.StatusType = 'CUTTING' THEN CAST(j.Duration AS float) ELSE 0 END), 0), 108), 
        '00:00:00'
    ) AS CuttingDuration,
    ISNULL(
        CONVERT(varchar, DATEADD(SECOND, SUM(CASE WHEN j.StatusType = 'ERROR' THEN CAST(j.Duration AS float) ELSE 0 END), 0), 108), 
        '00:00:00'
    ) AS ErrorDuration,
    ISNULL(
        CONVERT(varchar, DATEADD(SECOND, SUM(CASE WHEN j.StatusType = 'IDLE' THEN CAST(j.Duration AS float) ELSE 0 END), 0), 108), 
        '00:00:00'
    ) AS IdleDuration,
    ISNULL(
        CONVERT(varchar, DATEADD(SECOND, SUM(CASE WHEN j.StatusType = 'PIERCING' THEN CAST(j.Duration AS float) ELSE 0 END), 0), 108), 
        '00:00:00'
    ) AS PiercingDuration,
    ISNULL(
        CONVERT(varchar, DATEADD(SECOND, SUM(CASE WHEN j.StatusType = 'PREHEATING' THEN CAST(j.Duration AS float) ELSE 0 END), 0), 108), 
        '00:00:00'
    ) AS PreheatingDuration,
    ISNULL(
        CONVERT(varchar, DATEADD(SECOND, SUM(CASE WHEN j.StatusType = 'POSITIONING' THEN CAST(j.Duration AS float) ELSE 0 END), 0), 108), 
        '00:00:00'
    ) AS PositioningDuration,
    -- PlannedTime przekształcone na format czasu
    ISNULL(
        CONVERT(varchar, DATEADD(SECOND, CAST(planned.PlannedTime AS float), 0), 108), 
        '00:00:00'
    ) AS PlannedTimeFormatted,
    st.Status OverallStatus
FROM 
    PartCheck.dbo.Jobtable j2
CROSS APPLY 
    OPENJSON(j2.msg, '$.States') WITH (
        StatusType nvarchar(50) '$.Status.StatusType',
        Duration float '$.Duration'
    ) AS j
CROSS APPLY 
    OPENJSON(j2.msg, '$.Plans[0].Data') WITH (
        PlannedTime float '$.PlannedTime'
    ) AS planned
CROSS APPLY 
	OPENJSON(j2.msg, '$.Plans[0]') 
	WITH (
        Status nvarchar(20) '$.Status'
    ) AS st
WHERE
    DATEADD(hour, 2, j2.[_internal_timestamp]) >= '2024-09-03'
    AND DATEADD(hour, 2, j2.[_internal_timestamp]) < DATEADD(DAY, 1, '2024-09-03')
GROUP BY 
st.Status,
	JSON_VALUE(j2.msg, '$.PartProgramName'),
	j2.[_internal_timestamp],
	j2.[_internal_endtime],
    planned.PlannedTime,
    j2.id
ORDER BY 
    j2.[_internal_timestamp] DESC;
