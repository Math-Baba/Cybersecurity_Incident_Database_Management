USE CybersecurityIncidentManagementDB;

-- Procédure stockée pour que si une nouvelle faille est découverte, on l'ajouter à la table vulnerabilities avec le système associé à cette vulnérabilité
CREATE PROCEDURE sp_add_vulnerability
    @system_id INT,
    @cve_code NVARCHAR(50),
    @description NVARCHAR(1000),
    @patch_status NVARCHAR(50),
	@student_fullname NVARCHAR(100) 
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM systems WHERE system_id = @system_id)
        BEGIN
            RAISERROR('Le system_id fourni n’existe pas.', 16, 1);
            RETURN;
        END;

        INSERT INTO vulnerabilities (system_id, cve_code, description, patch_status, student_fullname)
        VALUES (@system_id, @cve_code, @description, @patch_status, @student_fullname);

        PRINT 'Nouvelle vulnérabilité ajoutée avec succès.';
    END TRY
    BEGIN CATCH
        PRINT 'Erreur : ' + ERROR_MESSAGE();
    END CATCH
END;

-- Vue pour visualiser le nombre de vulnérabilités par système
CREATE VIEW Vue_Vuln_By_Systems AS
SELECT s.system_id, s.name, s.os, COUNT(v.vuln_id) AS nb_vulnerabilities
FROM Systems s
LEFT JOIN Vulnerabilities v ON v.system_id = s.system_id 
GROUP BY s.system_id, s.name, s.os;

SELECT * FROM Vue_Vuln_By_Systems;

-- Table qui contiendra les alertes de vulnérabilités
CREATE TABLE VulnerabilityAlerts (
    alert_id INT IDENTITY(1,1) PRIMARY KEY,
    system_id INT NOT NULL,
    cve_code NVARCHAR(50) NOT NULL,
    alert_date DATETIME NOT NULL,
    CONSTRAINT FK_VA_System FOREIGN KEY (system_id)
        REFERENCES Systems(system_id)
);


-- Trigger d'alertes lorsqu'une vulnérabilité à été ajouté
CREATE TRIGGER trg_LogUnpatchedVulnerability
ON Vulnerabilities
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
	-- Insère une alerte uniquement pour les vulnérabilités non patchées
    INSERT INTO VulnerabilityAlerts (system_id, cve_code, alert_date)
    SELECT 
        i.system_id,
        i.cve_code,
        GETDATE()
    FROM inserted i
    WHERE i.patch_status = 'unpatched';
END;


-- Ajout d'une nouvelle faille dans la db
EXEC sp_add_vulnerability '3', 'CVE-9877-2267', 'faille critique affecte le système de gestion des raccourcis de Linux (.lnk).', 'Unpatched', 'Roland Laval Mathieu Baba'

SELECT * FROM VulnerabilityAlerts;

-- Table Historique des vulnérabilités patché
CREATE TABLE PatchHistory (
    patch_id INT IDENTITY(1,1) PRIMARY KEY,
    vuln_id INT NOT NULL,
    system_id INT NOT NULL,
    patch_date DATETIME NOT NULL DEFAULT GETDATE(),
    note NVARCHAR(300),

    FOREIGN KEY (vuln_id) REFERENCES Vulnerabilities(vuln_id),
    FOREIGN KEY (system_id) REFERENCES Systems(system_id)
);

-- Transaction pour mettre à jour le statut d'une vulnérabilité + garder un historique
DECLARE @vuln_id INT = 5;
DECLARE @system_id INT;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Vérification si la vulnérabilité existe
    IF NOT EXISTS (SELECT 1 FROM Vulnerabilities WHERE vuln_id = @vuln_id)
    BEGIN
        RAISERROR('Cette vulnérabilité n’existe pas.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Récupérer le système associé
    SELECT @system_id = system_id
    FROM Vulnerabilities
    WHERE vuln_id = @vuln_id;

    -- Mettre à jour le statut de la vulnérabilité sur patched
    UPDATE Vulnerabilities
    SET patch_status = 'patched'
    WHERE vuln_id = @vuln_id;

    -- Insérer l'événement dans l'historique
    INSERT INTO PatchHistory (vuln_id, system_id, note)
    VALUES (@vuln_id, @system_id, 'Patch appliqué avec succès.');

    -- Valider la transaction
    COMMIT TRANSACTION;
    PRINT 'Patch appliqué et historisé avec succès.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Erreur : ' + ERROR_MESSAGE();
END CATCH;

SELECT * FROM PatchHistory