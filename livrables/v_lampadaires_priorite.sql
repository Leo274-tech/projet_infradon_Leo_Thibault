-- Active: 1776325076709@@127.0.0.1@5432@infradon
-- Requête minimale
SELECT im.id_inventaire_mobilier, (COUNT(i.*) * 3) + (EXTRACT(YEAR FROM AGE (im.date_installation)) * 2) + (COALESCE(SUM(i.cout_materiau), 0) / 100) AS score
FROM
    inventaire_mobiliers im
    LEFT JOIN interventions i ON im.id = i.id_inventaire_mobilier
    INNER JOIN types_inventaire ti ON im.id_type_inventaire = ti.id
WHERE
    ti.libelle = 'lampadaire'
GROUP BY
    im.id_inventaire_mobilier,
    im.date_installation
ORDER BY score DESC;

-- Requête complète (avec plus de contexte)
WITH
    nb_par_zone AS (
        SELECT im.lieu, COUNT(im.lieu) AS nb_lampadaire
        FROM
            inventaire_mobiliers im
            INNER JOIN types_inventaire ti ON im.id_type_inventaire = ti.id
        WHERE
            ti.libelle = 'lampadaire'
        GROUP BY
            lieu
    )
SELECT
    im.id_inventaire_mobilier,
    ti.libelle,
    im.lieu,
    nz.nb_lampadaire AS nb_dans_lieu,
    COUNT(i.*) AS nombre_intervention,
    EXTRACT(YEAR FROM AGE (im.date_installation)) AS age_en_annees,
    COALESCE(SUM(i.cout_materiau), 0) AS cout_total,
    (COUNT(i.id) * 3) + (EXTRACT(YEAR FROM AGE (im.date_installation)) * 2) + (COALESCE(SUM(i.cout_materiau), 0) / 100) AS score_final
FROM
    inventaire_mobiliers im
    LEFT JOIN interventions i ON im.id = i.id_inventaire_mobilier
    INNER JOIN types_inventaire ti ON im.id_type_inventaire = ti.id
    INNER JOIN nb_par_zone nz ON im.lieu = nz.lieu
WHERE
    ti.libelle = 'lampadaire'
GROUP BY
    im.id_inventaire_mobilier,
    ti.libelle,
    im.lieu,
    nz.nb_lampadaire,
    im.date_installation
ORDER BY score_final DESC;