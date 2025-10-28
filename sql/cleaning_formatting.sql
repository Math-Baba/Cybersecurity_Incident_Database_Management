USE CybersecurityIncidentManagementDB;

WITH CTE_name AS (
    SELECT
		analyst_id,
        name,
        -- enlever les caractères spéciaux au début et à la fin
        SUBSTRING(
            name,
            PATINDEX('%[^@#!]%', name),  
            LEN(name) 
            - PATINDEX('%[^@#!]%', name) 
            - PATINDEX('%[^@#!]%', REVERSE(name)) + 2 
        ) AS cleaned_name
    FROM Analysts
),
-- CTE pour repérer les doublons de noms parmi les noms nettoyés
CTE_doublon AS (
	SELECT analyst_id, cleaned_name,
	ROW_NUMBER() OVER(PARTITION BY cleaned_name ORDER BY (analyst_id)) AS rn
	FROM CTE_name
)
-- Supprime tous les doublons de la table réelle
DELETE a
FROM Analysts a
JOIN CTE_doublon d
    ON a.analyst_id = d.analyst_id  
WHERE d.rn > 1;

-- Met à jour les noms nettoyés de la table réelle
UPDATE a
SET a.name = c.cleaned_name
FROM Analysts a
JOIN CTE_name c
    ON a.analyst_id = c.analyst_id;

SELECT * FROM Incidents, Systems, Threats, Vulnerabilities