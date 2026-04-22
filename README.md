# Projet Léo & Thibault

## Analyse
### Problèmes de qualité
- Les données ne sont pas normalisées : tables de valeurs à faire impérativement
- Certaines cases sont NULL alors qu’elles ne devraient pas : implémenter des contraintes NOT NULL
- Les colonnes latitude / longitude doivent être transformées en geom

### Colonnes utiles
Quelles colonnes sont utiles pour répondre au brief?

### Relations entre les fichiers excel
-> Voir MCD

### Éléments manquants
Quelles éléments sont manquants pour répondre au brief?

## Notes
- Certains fichier CSV ont été modifiés manuellement pour corriger des erreurs de frappe ou d'orthographe permettant ainsi de remplir entièrement les tables de liaison. [voir `img/Screenshot 2026-04-22 at 6.31.21 PM.png`]

- La description de interventions(objet) n'était pas assez précise our relier les inventaire_mobiliers et les interventions. Certains lieux possèdent plusieurs objets du même type les rendant indistinguables. Nous avons donc choisi d'attribuer l'intervention à l'**objet d'inventaire le plus ancien** en cas de doute.


## Modlèle Conceptuel de Données (MCD)
Lien du diagramme : [clique ici](https://app.diagrams.net/#G1RyfIgxZ6X6b_RugQosdPgRoexjX0Adxi#%7B%22pageId%22%3A%225_qenR7KUMMb5oFbrNIR%22%7D)

## Modlèle Logique de Données (MLD)
Lien du diagramme : [clique ici](https://app.diagrams.net/#G1RyfIgxZ6X6b_RugQosdPgRoexjX0Adxi#%7B%22pageId%22%3A%225_qenR7KUMMb5oFbrNIR%22%7D)

## Modlèle Physique de Données (MPD)
Voir `init-db/01-init.sql`