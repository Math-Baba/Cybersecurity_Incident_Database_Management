USE CybersecurityIncidentManagementDB;

------------------------------------SUPRESSION DES DOUBLONS ----------------------------------------
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

------------------------------ MIS A JOUR DES NOMS ------------------------------
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
-- Met à jour les noms nettoyés de la table réelle
UPDATE a
SET a.name = c.cleaned_name
FROM Analysts a
JOIN CTE_name c
    ON a.analyst_id = c.analyst_id;

-- Visualisation des autres données sales
SELECT owner,risk_level FROM Systems, Threats

-- Création d'une fonction qui va prendre en paramètre une chaîne et renvoyée le texte nettoyé
CREATE FUNCTION dbo.fn_clean_text(@text NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- On retourne directement le texte nettoyé
    RETURN CASE
        WHEN @text IS NULL OR LTRIM(RTRIM(@text)) = '' THEN @text
        ELSE SUBSTRING(
            @text,
            CASE WHEN PATINDEX('%[^*@#/<>$^! ]%', @text) = 0 THEN 1 ELSE PATINDEX('%[^*@#/<>$^! ]%', @text) END,
            LEN(@text)
            - CASE WHEN PATINDEX('%[^*@#/<>$^! ]%', @text) = 0 THEN 1 ELSE PATINDEX('%[^*@#/<>$^! ]%', @text) END
            - CASE WHEN PATINDEX('%[^*@#/<>$^! ]%', REVERSE(@text)) = 0 THEN 1 ELSE PATINDEX('%[^*@#/<>$^! ]%', REVERSE(@text)) END
            + 2
        )
    END
END;
GO

-- CTE pour visualiser les données sales vs données nettoyés avant mis à jour définitif
WITH CTE_cleaned_data AS (
    SELECT
        a.analyst_id,
        a.name,
        dbo.fn_clean_text(a.name) AS cleaned_name,
		s.system_id,
        s.owner,
        dbo.fn_clean_text(s.owner) AS cleaned_owner,
		t.threat_id,
        t.risk_level,
        UPPER(dbo.fn_clean_text(t.risk_level)) AS cleaned_risk_level 
    FROM Analysts a
    CROSS JOIN Systems s
    CROSS JOIN Threats t
)

-- Nettoyage de la colonne owner de la table Systems
UPDATE Systems
SET owner = dbo.fn_clean_text(owner);

-- Nettoyage de la colonne rik_level + mis à jour en majuscule de la table Threats
UPDATE Threats
SET risk_level = UPPER(dbo.fn_clean_text(risk_level));

-- Visualisation des données après nettoyage
SELECT owner,risk_level FROM Systems, Threats




