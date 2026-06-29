GastroPOS

GastroPOS est une application web moderne, ergonomique et performante de gestion de point de restauration, développée dans le cadre du projet de Génie Logiciel (**Thème 06**) à l'**École Nationale Supérieure Polytechnique de Douala (ENSPD)**.

L'application implémente une charte graphique immersive haut de gamme (Glow-Mix / Stone-Amber), un suivi des flux de commandes en temps réel, un moteur de calcul automatique des recettes journalières nettes (en FCFA), ainsi qu'une gestion matricielle des stocks avec déstockage automatisé lors des ventes.

---

🛠️ Stack Technologique & Architecture

- **Backend :** Python 3 / Flask (Architecture MVC)
- **Frontend :** HTML5 / CSS3 avec Tailwind CSS v4 & Fetch API (AJAX asynchrone)
- **Base de données :** MySQL Workbench (`new_schema`) avec gestion stricte de l'intégrité référentielle en cascade (3NF).

---

Prérequis & Installation

### 1. Cloner le dépôt GitHub
Ouvrez votre terminal et positionnez-vous dans votre dossier de travail :
```bash
git clone [https://github.com/votre-username/Gestion_resto.git](https://github.com/votre-username/Gestion_resto.git)
cd Gestion_resto
2. Configuration de la Base de Données (MySQL Workbench)
Lancez MySQL Workbench ou votre client MySQL local.

Ouvrez et exécutez l'intégralité du script SQL fourni à la racine : database.sql.
Ce script va automatiquement créer la base de données new_schema, structurer les 5 tables (produit, commande, ligne_commande, ingredient, recette) et injecter les données initiales (Chou blanc, Banane Plantain, Huile de friture, etc.).

3. Configuration des Accès MySQL dans le Code
Vérifiez ou adaptez les identifiants de connexion à votre instance locale dans le fichier app.py :

Python
db_config = {
    'host': 'localhost',
    'user': 'resto_user',      # Remplacez par votre utilisateur MySQL (ex: root)
    'password': 'resto123',    # Remplacez par votre mot de passe MySQL
    'database': 'new_schema'
}
4. Installation des Dépendances Python
Il est fortement recommandé d'utiliser un environnement virtuel. Ouvrez votre terminal à la racine du projet :

Sur Windows :

Bash
python -m venv venv
venv\Scripts\activate
pip install flask mysql-connector-python
Sur macOS / Linux :

Bash
python3 -m venv venv
source venv/bin/activate
pip install flask mysql-connector-python
Lancement de l'Application
Une fois les dépendances installées et la base de données en ligne, exécutez le serveur Flask :

Bash
python app.py
(ou python3 app.py selon votre configuration)

Le terminal va vous indiquer que le serveur tourne localement. Ouvrez votre navigateur web et accédez à l'adresse suivante :
👉 http://127.0.0.1:5000

Fonctionnalités Implémentées à Tester
Prise de commande (/) : Interface point de vente (POS) interactive. Sélectionnez des produits, ajustez les quantités dans le panier, saisissez une référence client ou un numéro de table, puis validez.

Déstockage Automatique : À chaque commande validée, les stocks d'ingrédients correspondants (configurés matriciellement dans la table recette) sont instantanément soustraits en base de données.

Tableau de Bord (/dashboard) : - Visualisation du flux des commandes en temps réel.

Modification dynamique du statut d'une commande (En attente, Servi, Payé).

Calcul automatisé et instantané du Chiffre d'affaires / Recettes du jour (uniquement pour les commandes passées au statut Payé).

Suivi visuel de l'état des stocks avec un système d'alerte critique (le badge passe au rouge si la quantité d'un ingrédient est inférieure à 10 unités).

Auteurs & Supervision
Développé par : Raye Kitou Fatima (Génie Logiciel - Niveau 4)

Sous la supervision de : Dr. MALONG Yannick (ENSPD)
