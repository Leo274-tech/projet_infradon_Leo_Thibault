CREATE EXTENSION IF NOT EXISTS postgis;

-- CRÉATION DES RÔLES (avec des mots de passe à redéfinir en production)
CREATE ROLE admin;

CREATE ROLE analyste;

CREATE ROLE citoyen;

CREATE ROLE responsable;

CREATE ROLE technicien;

-- ACCÈS AU SCHÉMA public
GRANT USAGE ON SCHEMA public TO admin,
analyste,
citoyen,
responsable,
technicien;

-- ATTRIBUTION DES PRIVILÈGES SPÉCIFIQUES
-- ==========================================
-- ADMIN : Data engineer
-- ==========================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;

-- ==========================================
-- ANALYSTE : Lecture seule
-- ==========================================
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyste;

-- ==========================================
-- CITOYEN : Signalements restrictifs
-- ==========================================
GRANT
SELECT
    ON inventaire_mobiliers,
    types_inventaire,
    etats_inventaire,
    types_materiau,
    urgences_signalement TO citoyen;

GRANT INSERT ON signalements TO citoyen;

GRANT USAGE, SELECT ON SEQUENCE signalements_id_seq TO citoyen; -- pour incrémenter l'ID lors de l'INSERT

-- ==========================================
-- RESPONSABLE : Opérationnel complet
-- ==========================================
GRANT
SELECT, INSERT,
UPDATE ON ALL TABLES IN SCHEMA public TO responsable;

GRANT USAGE,
SELECT,
UPDATE ON ALL SEQUENCES IN SCHEMA public TO responsable;

-- ==========================================
-- TECHNICIEN : Vue globale, actions ciblées
-- ==========================================
GRANT SELECT ON ALL TABLES IN SCHEMA public TO technicien;

GRANT INSERT, UPDATE ON interventions TO technicien;

GRANT USAGE, SELECT ON SEQUENCE interventions_id_seq TO technicien;

GRANT UPDATE ON signalements TO technicien;

-- Fonctions
-- Création d'une fonction pour normaliser une date (On effectue cette opération 3 fois.)
CREATE FUNCTION normalize_date(date_string TEXT)
RETURNS DATE 
LANGUAGE sql
IMMUTABLE
AS $$
SELECT 
    CASE
        -- Format: YYYY
        WHEN date_string ~ '^\d{4}$' THEN 
            TO_DATE('01.01.' || date_string, 'DD.MM.YYYY')

        -- Format: DD.MM.YYYY
        WHEN date_string ~ '^\d{2}\.\d{2}\.\d{4}$' THEN 
            TO_DATE(date_string, 'DD.MM.YYYY')

        -- Format: YYYY-MM-DD
        WHEN date_string ~ '^\d{4}-\d{2}-\d{2}$' THEN 
            TO_DATE(date_string, 'YYYY-MM-DD')

        -- Format: mois YYYY
        WHEN date_string ~* '^[a-zâéû]+ \d{4}$' THEN 
            TO_DATE(
                '01.' || 
                CASE LOWER(split_part(date_string, ' ', 1))
                    WHEN 'janvier'   THEN '01'
                    WHEN 'février'   THEN '02'
                    WHEN 'mars'      THEN '03'
                    WHEN 'avril'     THEN '04'
                    WHEN 'mai'       THEN '05'
                    WHEN 'juin'      THEN '06'
                    WHEN 'juillet'   THEN '07'
                    WHEN 'août'      THEN '08'
                    WHEN 'septembre' THEN '09'
                    WHEN 'octobre'   THEN '10'
                    WHEN 'novembre'  THEN '11'
                    WHEN 'décembre'  THEN '12'
                END || '.' || split_part(date_string, ' ', 2),
                'DD.MM.YYYY'
            )
        ELSE NULL
    END;
$$;