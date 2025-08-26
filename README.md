# simple_carshop_mta

---

https://github.com/user-attachments/assets/56cb5f9f-d3c2-40ab-ae7a-dca6b3d71a87

---

##  Principe du Carshop

| **Composant** | **Fonctionnalité** |
|---------------|---------------------|
| **Showroom** | Liste de véhicules prédéfinis exposés avec modèle, nom, année et prix. |
| **Spawn Véhicules** | Les voitures sont créées dans la concession avec couleur aléatoire, gelées et invulnérables. |
| **Pickup devant véhicule** | Permet au joueur d’afficher les infos du véhicule lorsqu’il s’en approche. |
| **Vendeur (NPC)** | Ped statique : quand le joueur entre dans sa zone, la boutique s’ouvre. |
| **Boutique (GUI)** | Fenêtre listant les voitures disponibles (Nom, Prix, Statut). Boutons : `Acheter`, `Infos`, `Fermer`. |
| **Fenêtre Infos** | Affiche les détails d’un véhicule (Nom, Modèle, Année, Prix, Description). |
| **Prévisualisation** | Le joueur peut voir le véhicule dans une zone spéciale, choisir une couleur via une **palette interactive**, puis appliquer/acheter/annuler. |
| **Achat** | Vérifie l’argent du joueur : <br> - Si assez d’argent → véhicule créé au spawn d’achat, retiré du showroom, marqué vendu. <br> - Sinon → message d’erreur (`Pas assez d'argent`). |
| **Synchronisation** | Après chaque achat, la liste des véhicules est mise à jour pour tous les joueurs. |
| **Respawn Automatique** | Le showroom est réinitialisé toutes les 15 minutes pour réapparaitre les voitures. |

---

##  Fonctionnement Global

| **Étape** | **Côté Client (GUI)** | **Côté Serveur (Logiciel)** |
|-----------|------------------------|-----------------------------|
| 1 | Le joueur approche le vendeur et ouvre la boutique. | Le serveur envoie la liste des véhicules disponibles (`carshop:syncShowroom`). |
| 2 | Le joueur sélectionne une voiture et consulte les infos ou lance la prévisualisation. | Vérification que le véhicule est disponible. |
| 3 | En mode prévisualisation, le joueur choisit une couleur depuis la palette. | - |
| 4 | Le joueur clique sur `Purchase`. | Vérifie l’argent → retire le montant → crée le véhicule avec la couleur choisie au point de spawn. |
| 5 | Le joueur reçoit son véhicule et est directement placé dedans. | Le showroom est mis à jour et synchronisé pour tout le monde. |

---
