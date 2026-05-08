SELECT 
    i.id_inventaire,
    i.geom AS position,
    i.id_type_inventaire,
    i.id_etat,
    i.date_installation,
    i.remarques,

    tm.libelle AS materiau,
    ei.libelle AS etat,
    us.libelle AS urgence,

    CASE
    WHEN ei.libelle = 'Hors service' THEN 100
    WHEN ei.libelle = 'Dégradé' THEN 50
    ELSE 10
END AS score_priorite

FROM inventaires i

LEFT JOIN types_materiau tm
    ON i.id_type_materiau = tm.id

LEFT JOIN etats_inventaire ei
    ON i.id_etat = ei.id

LEFT JOIN signalements s
    ON i.id = s.id_inventaire

LEFT JOIN urgences_signalement us
    ON s.id_urgences_signalement = us.id

    AVG (couts_materiau) AS cout_moyen -- calcul du cout moyen de remplacement