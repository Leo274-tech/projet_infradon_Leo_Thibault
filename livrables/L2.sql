-- Active: 1776325076709@@127.0.0.1@5432@infradon
-- Requête minimale
SELECT
    im.id_inventaire,
    (COUNT(i.*) * 3) + (EXTRACT(YEAR FROM AGE(im.date_installation)) * 2) + (SUM(i.cout_materiau) / 100) AS score
FROM
    inventaire_mobiliers im
    LEFT JOIN interventions_inventaires a ON im.id = a.id_inventaire
    LEFT JOIN interventions i ON a.id_intervention = i.id
    INNER JOIN types_inventaire ti ON im.id_type_inventaire = ti.id
WHERE
    ti.libelle = 'lampadaire'
GROUP BY
    im.id_inventaire,
    im.date_installation
ORDER BY
    score DESC NULLS LAST;


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
    im.id_inventaire,
    ti.libelle,
    im.lieu,
    nz.nb_lampadaire AS nb_dans_lieu,
    COUNT(i.*) AS nombre_intervention,
    EXTRACT(YEAR FROM AGE(im.date_installation)) AS age_en_annees,
    SUM(i.cout_materiau) AS cout_total,
    (COUNT(i.*) * 3) + (EXTRACT(YEAR FROM AGE(im.date_installation)) * 2) + (SUM(i.cout_materiau) / 100) AS score_final
FROM
    inventaire_mobiliers im
    LEFT JOIN interventions_inventaires a ON im.id = a.id_inventaire
    LEFT JOIN interventions i ON a.id_intervention = i.id
    INNER JOIN types_inventaire ti ON im.id_type_inventaire = ti.id
    INNER JOIN nb_par_zone nz ON im.lieu = nz.lieu
WHERE
    ti.libelle = 'lampadaire'
GROUP BY
    im.id_inventaire,
    ti.libelle,
    im.lieu,
    nz.nb_lampadaire,
    im.date_installation
ORDER BY
    score_final DESC NULLS LAST;