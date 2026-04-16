# Structure d'une requête de nettoyage

## Tables normalisation
```
INSERT INTO public.table (colonne1, colonne2)
VALUES ('value1', 'value2')
FROM staging.table
```

## Tables entités
```
INSERT INTO public.table (colonne1, colonne2)
SELECT
CASE
WHEN ... THEN ...
WHEN ... THEN ...
ELSE ...
END as value1,
CASE
WHEN ... THEN ...
WHEN ... THEN ...
ELSE ...
END as value2
FROM staging.table;
```