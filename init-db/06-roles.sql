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