-- Active: 1772794232287@@127.0.0.1@5432@infradon
SELECT COUNT(*) FROM staging.inventaire_mobiliers;  -- ~120
SELECT COUNT(*) FROM staging.signalements;         -- ~200
SELECT COUNT(*) FROM staging.interventions;        -- ~150
SELECT COUNT(*) FROM staging.fournisseurs;         -- ~15

-- Types de mobilier
SELECT type_inventaire, COUNT(*) FROM staging.inventaire_mobiliers GROUP BY type_inventaire ORDER BY 2 DESC;

-- Matériaux
SELECT materiau, COUNT(*) FROM staging.inventaire_mobiliers GROUP BY materiau;

-- Formats de date
SELECT date_installation, COUNT(*)
FROM staging.inventaire_mobiliers
GROUP BY date_installation ORDER BY 2 DESC LIMIT 20;

-- Coûts
SELECT cout_materiau, COUNT(*) FROM staging.interventions GROUP BY cout_materiau ORDER BY 2 DESC;

-- Durées
SELECT duree, COUNT(*) FROM staging.interventions GROUP BY duree;

-- Techniciens
SELECT technicien, COUNT(*) FROM staging.interventions GROUP BY technicien ORDER BY 2 DESC;

-- Doublons potentiels (même lieu + type)
SELECT lieu, type_inventaire, COUNT(*) FROM staging.inventaire_mobiliers
GROUP BY lieu, type_inventaire HAVING COUNT(*) > 1;