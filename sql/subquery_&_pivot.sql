USE CybersecurityIncidentManagementDB;

-- Nombre d'incidents par analyste supérieur à 0
SELECT 
    a.name AS analyst_name,
    COUNT(i.incident_id) AS analysts_with_incidents
FROM Analysts a
LEFT JOIN Incidents i ON a.analyst_id = i.analyst_id
GROUP BY a.name
HAVING COUNT(i.incident_id)>0
ORDER BY analysts_with_incidents DESC;

-- Nombre d'incidents par analyste égal à 0
SELECT 
    a.name AS analyst_name,
    COUNT(i.incident_id) AS analyst_with_no_incidents
FROM Analysts a
LEFT JOIN Incidents i ON a.analyst_id = i.analyst_id
GROUP BY a.name
HAVING COUNT(i.incident_id)=0;

-- Total d'analystes avec et sans incidents attribués
WITH IncidentCounts AS (
    SELECT 
        a.analyst_id,
        COUNT(i.incident_id) AS total_incidents
    FROM Analysts a
    LEFT JOIN Incidents i ON a.analyst_id = i.analyst_id
    GROUP BY a.analyst_id
)
SELECT
    SUM(CASE WHEN total_incidents > 0 THEN 1 ELSE 0 END) AS analysts_with_incidents,
    SUM(CASE WHEN total_incidents = 0 THEN 1 ELSE 0 END) AS analysts_without_incidents
FROM IncidentCounts;


-- Le nombre d'incidents gérés par chaque Analyste par catégorie de niveau de risque 
SELECT *
FROM (
    SELECT 
        a.name AS AnalystName,
        t.risk_level
    FROM Analysts a
    JOIN Incidents i ON a.analyst_id = i.analyst_id
    JOIN IncidentThreats it ON i.incident_iD = it.incident_id
    JOIN Threats t ON it.threat_id = t.threat_id
) src
PIVOT (
    COUNT(risk_level)
    FOR risk_level IN ([Low], [Medium], [High])
) AS pvt;



-- CTE pour le nombre d'analystes avec 0 incidents
WITH AnalystsZero AS (
    SELECT 
        a.analyst_id, name,
        ROW_NUMBER() OVER (ORDER BY a.analyst_id) AS rn
    FROM Analysts a
    LEFT JOIN Incidents i ON a.analyst_id = i.analyst_id
    GROUP BY a.analyst_id, a.name
    HAVING COUNT(i.incident_id) = 0
),
-- CTE pour le nombre d'analystes avec plus de 1 incidents à gérer
AnalystsWithTwoOrMore AS (
    SELECT a.analyst_id, a.name
    FROM Analysts a
    JOIN Incidents i ON a.analyst_id = i.analyst_id
    GROUP BY a.analyst_id, a.name
    HAVING COUNT(i.incident_id) > 1
),
-- 
IncidentsToMove AS (
    SELECT 
        i.incident_id, i.analyst_id,
        ROW_NUMBER() OVER (ORDER BY i.reported_date) AS rn -- numérote les incidents pour les mapper 1‑à‑1 aux analystes à 0 incident.
    FROM Incidents i
    JOIN AnalystsWithTwoOrMore a ON i.analyst_id = a.analyst_id -- On ne prends que les incidents des analystes ayant au moins 2 incidents à traiter
)
UPDATE i
SET i.analyst_id = z.analyst_id
FROM Incidents i
JOIN IncidentsToMove m ON i.incident_id = m.incident_id -- on relie chaque incident à son numéro de ligne
JOIN AnalystsZero z ON m.rn = z.rn;  -- on mappe un incident à un analyste ayant 0 incidents 





