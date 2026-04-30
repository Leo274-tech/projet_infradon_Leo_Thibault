-- Active: 1772794232287@@127.0.0.1@5432@infradon
SELECT 
    i.id_inventaire AS id_lampadaire,
    i.lieu AS lieu_lampadaire,
    tm.libelle AS materiau,
    EXTRACT(YEAR FROM i.date_installation) AS annee_installation,

    COUNT(inter.id) AS nb_pannes,
    COALESCE(SUM(inter.cout_materiau), 0) AS cout_total,
    MAX(inter.date_intervention) AS derniere_intervention,

    ST_AsText(i.geom) AS coordonnees

FROM inventaire_mobiliers i

LEFT JOIN types_inventaire t 
    ON i.id_type_inventaire = t.id

LEFT JOIN interventions_inventaires ii
    ON i.id = ii.id_inventaire

LEFT JOIN interventions inter
    ON ii.id_intervention = inter.id

    LEFT JOIN types_materiau tm 
    ON i.id_type_materiau = tm.id 

WHERE t.libelle = 'lampadaire'

GROUP BY
    i.id, i.lieu, t.libelle, i.date_installation, i.geom, tm.libelle;