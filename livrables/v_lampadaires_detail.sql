-- Active: 1772794232287@@127.0.0.1@5432@infradon
SELECT 
    im.id_inventaire AS id_lampadaire,
    im.lieu AS lieu_lampadaire,
    tm.libelle AS materiau,
    EXTRACT(YEAR FROM im.date_installation) AS annee_installation,

    COUNT(i.id) AS nb_pannes,
    COALESCE(SUM(i.cout_materiau), 0) AS cout_total,
    MAX(i.date_intervention) AS derniere_intervention,

    ST_AsText(im.geom) AS coordonnees

FROM inventaire_mobiliers im

LEFT JOIN types_inventaire t 
    ON im.id_type_inventaire = t.id

LEFT JOIN interventions i
    ON im.id = i.id_inventaire

    LEFT JOIN types_materiau tm 

    ON im.id_type_materiau = tm.id 

WHERE t.libelle = 'lampadaire'

GROUP BY
    im.id, im.lieu, t.libelle, im.date_installation, im.geom, tm.libelle;