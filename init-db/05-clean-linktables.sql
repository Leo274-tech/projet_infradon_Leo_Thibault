
WITH
    fournisseurs_normalises AS (
        SELECT entreprise, regexp_split_to_table(id_type_inventaire, ',') AS types_normalises
        FROM staging.fournisseurs
    )
INSERT INTO
    public.fournisseurs_typesinventaire (
        id_fournisseur,
        id_type_inventaire
    )
SELECT
    pf.id AS id_fournisseur,
    CASE
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%lampadaire%' THEN 1
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%fontaine%' THEN 2
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%banc%' THEN 3
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%poubelle%' THEN 4
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%corbeille%' THEN 4
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%borne%' THEN 5
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%panneau%' THEN 6
        ELSE 7 -- 'autre'
    END AS id_type_inventaire
FROM
    fournisseurs_normalises fn
    INNER JOIN public.fournisseurs pf ON fn.entreprise = pf.entreprise;