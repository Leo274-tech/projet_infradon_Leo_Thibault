-- Active: 1776325076709@@127.0.0.1@5432@infradon
SELECT COUNT(*) FROM staging.inventaire_mobiliers;
-- ~120
SELECT COUNT(*) FROM staging.signalements;
-- ~200
SELECT COUNT(*) FROM staging.interventions;
-- ~150
SELECT COUNT(*) FROM staging.fournisseurs;
-- ~15

-- Types de mobilier
SELECT id_type_inventaire, COUNT(*)
FROM staging.inventaire_mobiliers
GROUP BY
    id_type_inventaire
ORDER BY 2 DESC;

-- Matériaux
SELECT id_materiau, COUNT(*)
FROM staging.inventaire_mobiliers
GROUP BY
    id_materiau;

-- Formats de date
SELECT date_installation, COUNT(*)
FROM staging.inventaire_mobiliers
GROUP BY
    date_installation
ORDER BY 2 DESC
LIMIT 20;

-- Coûts
SELECT cout_materiau, COUNT(*)
FROM staging.interventions
GROUP BY
    cout_materiau
ORDER BY 2 DESC;

-- Durées
SELECT duree, COUNT(*) FROM staging.interventions GROUP BY duree;

-- Techniciens
SELECT technicien, COUNT(*)
FROM staging.interventions
GROUP BY
    technicien
ORDER BY 2 DESC;

-- Doublons potentiels (même lieu + type)
SELECT lieu, id_type_inventaire, COUNT(*)
FROM staging.inventaire_mobiliers
GROUP BY
    lieu,
    id_type_inventaire
HAVING
    COUNT(*) > 1;

-- Interventions
SELECT DISTINCT
    ON (i.id) i.id,
    i.inventaire_mobilier,
    i.date_intervention,
    im.id,
    ti.libelle,
    im.lieu,
    im.date_installation
FROM
    public.inventaire_mobiliers im
    LEFT JOIN types_inventaire ti ON im.id_type_inventaire = ti.id
    INNER JOIN public.interventions i ON i.inventaire_mobilier ILIKE '%' || ti.libelle || '%' || im.lieu || '%'
ORDER BY i.id, im.date_installation ASC;

SELECT inventaire_mobilier, COUNT(*)
FROM public.interventions
GROUP BY
    inventaire_mobilier
HAVING
    COUNT(*) > 1;

SELECT im.id_inventaire, ti.libelle, im.lieu
FROM public.inventaire_mobiliers im
    LEFT JOIN types_inventaire ti ON im.id_type_inventaire = ti.id
WHERE
    ti.libelle = 'lampadaire';

-- Vérification des erreurs
SELECT i.id, i.inventaire_mobilier, i.date_intervention
FROM public.interventions i
    LEFT JOIN (
        SELECT DISTINCT
            ON (i.id) i.id AS id_intervention, im.id AS id_inventaire
        FROM
            public.inventaire_mobiliers im
            LEFT JOIN types_inventaire ti ON im.id_type_inventaire = ti.id
            INNER JOIN public.interventions i ON i.inventaire_mobilier ILIKE '%' || ti.libelle || '%' || im.lieu || '%'
        ORDER BY i.id, im.date_installation ASC
    ) b ON i.id = b.id_intervention
WHERE
    b.id_intervention IS NULL;

SELECT im.*
FROM
    interventions i
    INNER JOIN interventions_inventaires a ON i.id = a.id_intervention
    INNER JOIN inventaire_mobiliers im ON a.id_inventaire = im.id
    LEFT JOIN types_inventaire ti ON im.id_type_inventaire = ti.id
WHERE
    ti.libelle = 'lampadaire';

-- Signalements
-- Vérification des erreurs
SELECT s.id, s.inventaire_mobilier, s.date_signalement
FROM public.signalements s
    LEFT JOIN (
        SELECT DISTINCT
            ON (s.id) s.id AS id_signalement, im.id AS id_inventaire
        FROM
            public.inventaire_mobiliers im
            LEFT JOIN types_inventaire ti ON im.id_type_inventaire = ti.id
            INNER JOIN public.signalements s ON s.inventaire_mobilier ILIKE '%' || ti.libelle || '%' || im.lieu || '%'
        ORDER BY s.id, im.date_installation ASC
    ) b ON s.id = b.id_signalement
WHERE
    b.id_signalement IS NULL;

SELECT * FROM interventions_inventaires;

SELECT * FROM signalements_inventaires;

SELECT * FROM public.inventaire_mobiliers;

SELECT * FROM public.signalements;

SELECT * FROM public.interventions;

SELECT * FROM public.fournisseurs;

SELECT * FROM public.fournisseurs_typesinventaire;

SELECT id_type_inventaire FROM staging.fournisseurs;

SELECT tm.libelle
FROM
    inventaire_mobiliers
    LEFT JOIN types_materiau tm ON inventaire_mobiliers.id_type_materiau = tm.id;