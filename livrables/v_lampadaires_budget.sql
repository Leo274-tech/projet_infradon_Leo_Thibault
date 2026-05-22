WITH cout_moyen AS (

    SELECT 
        AVG(i.cout_materiau) AS cout_moyen

    FROM interventions i

    LEFT JOIN types_intervention ti
        ON i.type_intervention = ti.id

    WHERE ti.libelle = 'remplacement'
),

lampadaires_prioritaires AS (

    SELECT 
        inv.id_inventaire,
        inv.geom AS position,
        inv.id_type_inventaire,
        inv.id_etat,
        inv.date_installation,
        inv.remarques,

        tm.libelle AS materiau,
        ei.libelle AS etat,
        us.libelle AS urgence,

        CASE
            WHEN ei.libelle = 'à remplacer' THEN 100
            WHEN ei.libelle = 'Dégradé' THEN 50
            ELSE 10
        END AS score_priorite,

        cm.cout_moyen

    FROM inventaire_mobiliers inv

    LEFT JOIN types_materiau tm
        ON inv.id_type_materiau = tm.id

    LEFT JOIN etats_inventaire ei
        ON inv.id_etat = ei.id

    LEFT JOIN signalements s
        ON inv.id = s.id_inventaire

    LEFT JOIN urgences_signalement us
        ON s.id_urgence = us.id

    CROSS JOIN cout_moyen cm
),

budget_cumule AS (

    SELECT 
        *,

        SUM(cout_moyen) OVER (
            ORDER BY score_priorite DESC
        ) AS cout_cumule

    FROM lampadaires_prioritaires
)

SELECT *
FROM budget_cumule

WHERE cout_cumule <= 50000

ORDER BY score_priorite DESC;