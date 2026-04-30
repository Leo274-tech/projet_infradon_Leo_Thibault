# Projet Léo & Thibault

## Analyse
### Problèmes de Qualité
- Les données ne sont pas normalisées -> tables de valeurs à faire impérativement
- Certaines cases sont NULL alors qu’elles ne devraient pas -> implémenter des contraintes NOT NULL
- Les colonnes latitude / longitude doivent être transformées en geom

### Tables et Colonnes Importantes
Les tables inventaire_mobiliers et interventions vont être primordiales pour le brief.
inventaire_mobiliers :
- id_inventaire
- id_type_materiel
- lieu
- geom
- date_installation

interventions :
- date_intervention
- cout_materiau

interventions_inventaires :
- pour les jointures

### Éléments Manquants & Limites
Dans les interventions, les inventaires du même type et du même lieu ne sont pas différencié. Si deux lampadaires partagent la même zone, il devront donc se partager également le nombre d'interventions.

## Notes
- Certains fichier CSV ont été modifiés manuellement pour corriger des erreurs de frappe ou d'orthographe permettant ainsi de remplir entièrement les tables de liaison. [voir `img/Screenshot 2026-04-22 at 6.31.21 PM.png`]

- La description de interventions(objet) n'était pas assez précise our relier les inventaire_mobiliers et les interventions. Certains lieux possèdent plusieurs objets du même type les rendant indistinguables. Nous avons donc choisi d'attribuer l'intervention à l'**objet d'inventaire le plus ancien** en cas de doute.


## Modlèle Conceptuel de Données (MCD)
Lien du diagramme : [clique ici](https://app.diagrams.net/#G1RyfIgxZ6X6b_RugQosdPgRoexjX0Adxi#%7B%22pageId%22%3A%225_qenR7KUMMb5oFbrNIR%22%7D)

## Modlèle Logique de Données (MLD)
Lien du diagramme : [clique ici](https://app.diagrams.net/#G1RyfIgxZ6X6b_RugQosdPgRoexjX0Adxi#%7B%22pageId%22%3A%225_qenR7KUMMb5oFbrNIR%22%7D)
wqq
## Modlèle Physique de Données (MPD)
Voir `init-db/01-init.sql`