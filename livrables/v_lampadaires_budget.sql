WITH cout_moyen AS (

    SELECT 
        AVG(i.cout_materiau) AS cout_moyen

    FROM interventions i

    LEFT JOIN types_intervention ti
        ON i.type_intervention = ti.id

    WHERE ti.libelle = 'remplacement'
),

budget AS (

    SELECT 
        im.*,
        us.libelle AS urgence,

        SUM(cm.cout_moyen) OVER (
            ORDER BY us.libelle DESC NULLS LAST, im.id
        ) AS cout_cumule

    FROM inventaire_mobiliers im

    LEFT JOIN interventions i
        ON im.id = i.id_inventaire

    LEFT JOIN signalements s
        ON im.id = s.id_inventaire

    INNER JOIN urgences_signalement us
        ON s.id_urgence = us.id

    LEFT JOIN types_inventaire ti
        ON im.id_type_inventaire = ti.id

    CROSS JOIN cout_moyen cm

    WHERE ti.libelle = 'lampadaire'
)

SELECT *
FROM budget

WHERE cout_cumule <= 50000

ORDER BY urgence DESC NULLS LAST;