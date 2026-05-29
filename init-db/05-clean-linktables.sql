
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
    COALESCE(ti.id, (SELECT id FROM public.types_inventaire WHERE libelle = 'autre')) AS id_type_inventaire
FROM
    fournisseurs_normalises fn
    INNER JOIN public.fournisseurs pf ON LOWER(TRIM(fn.entreprise)) = LOWER(TRIM(pf.entreprise))
    LEFT JOIN public.types_inventaire ti ON (
        LOWER(TRIM(fn.types_normalises)) LIKE '%' || ti.libelle || '%'
        OR (LOWER(TRIM(fn.types_normalises)) LIKE '%corbeille%' AND ti.libelle = 'poubelle')
        OR (LOWER(TRIM(fn.types_normalises)) LIKE '%borne%' AND ti.libelle = 'borne recharge')
    );