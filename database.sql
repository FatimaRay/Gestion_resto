-- =================================================================
-- 1. CRÉATION DE LA BASE DE DONNÉES ET MISE EN EN PLACE
-- =================================================================
CREATE DATABASE IF NOT EXISTS `new_schema` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `new_schema`;

-- Désactiver temporairement les contraintes pour éviter les erreurs de suppression
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `recette`;
DROP TABLE IF EXISTS `ligne_commande`;
DROP TABLE IF EXISTS `ingredient`;
DROP TABLE IF EXISTS `commande`;
DROP TABLE IF EXISTS `produit`;
SET FOREIGN_KEY_CHECKS = 1;

-- =================================================================
-- 2. CRÉATION DES TABLES
-- =================================================================

-- Table 1 : Les Produits / Menus du restaurant
CREATE TABLE `produit` (
    `id_produit` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(100) NOT NULL,
    `prix` DECIMAL(10, 2) NOT NULL,
    `categorie` VARCHAR(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 2 : Les Commandes globales (Flux)
CREATE TABLE `commande` (
    `id_commande` INT AUTO_INCREMENT PRIMARY KEY,
    `reference_client` VARCHAR(100) NOT NULL, -- Numéro de table ou nom client
    `date_commande` DATETIME NOT NULL,
    `total` DECIMAL(10, 2) DEFAULT 0.00,
    `statut` VARCHAR(20) DEFAULT 'EN ATTENTE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 3 : Table de liaison / Lignes de commande (Menus choisis)
CREATE TABLE `ligne_commande` (
    `id_ligne` INT AUTO_INCREMENT PRIMARY KEY,
    `id_commande` INT NOT NULL,
    `id_produit` INT NOT NULL,
    `quantite` INT NOT NULL DEFAULT 1,
    FOREIGN KEY (`id_commande`) REFERENCES `commande`(`id_commande`) ON DELETE CASCADE,
    FOREIGN KEY (`id_produit`) REFERENCES `produit`(`id_produit`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 4 : Les Ingrédients en Stock
CREATE TABLE `ingredient` (
    `id_ingredient` INT AUTO_INCREMENT PRIMARY KEY,
    `nom` VARCHAR(100) NOT NULL,
    `quantite_stock` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `unite` VARCHAR(20) NOT NULL -- kg, pièces, litres, etc.
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table 5 : Les Recettes (Liaison Produits <-> Ingrédients requis)
CREATE TABLE `recette` (
    `id_recette` INT AUTO_INCREMENT PRIMARY KEY,
    `id_produit` INT NOT NULL,
    `id_ingredient` INT NOT NULL,
    `quantite_requise` DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (`id_produit`) REFERENCES `produit`(`id_produit`) ON DELETE CASCADE,
    FOREIGN KEY (`id_ingredient`) REFERENCES `ingredient`(`id_ingredient`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =================================================================
-- 3. PEUPLEMENT DES DONNÉES INITIALES (JEU DE TEST)
-- =================================================================

-- Insertion des Menus (Produits)
INSERT INTO `produit` (`id_produit`, `nom`, `prix`, `categorie`) VALUES
(1, 'Chou Épicé', 1500.00, 'Plat'),
(2, 'Alloco Grillé', 1000.00, 'Accompagnement'),
(3, 'Burger Gastro', 3500.00, 'Plat'),
(4, 'Jus de Bissap local', 500.00, 'Boisson');

-- Insertion des Ingrédients en stock
INSERT INTO `ingredient` (`id_ingredient`, `nom`, `quantite_stock`, `unite`) VALUES
(1, 'Chou blanc', 50.00, 'pcs'),
(2, 'Banane Plantain', 120.00, 'pcs'),
(3, 'Huile de friture', 20.00, 'L'),
(4, 'Steak haché', 40.00, 'pcs'),
(5, 'Pain Burger', 45.00, 'pcs'),
(6, 'Feuilles de Bissap', 15.00, 'kg');

-- Liens des Recettes (Soustraction automatique lors des ventes)
-- Pour 1 Chou Épicé (Id 1) -> Requis: 0.5 Chou (Id 1)
INSERT INTO `recette` (`id_produit`, `id_ingredient`, `quantite_requise`) VALUES
(1, 1, 0.50),
-- Pour 1 Alloco (Id 2) -> Requis: 2 Bananes (Id 2) + 0.1L Huile (Id 3)
(2, 2, 2.00),
(2, 3, 0.10),
-- Pour 1 Burger (Id 3) -> Requis: 1 Pain (Id 5) + 1 Steak (Id 4)
(3, 4, 1.00),
(3, 5, 1.00),
-- Pour 1 Jus Bissap (Id 4) -> Requis: 0.05kg de feuilles (Id 6)
(4, 6, 0.05);

-- Ajout d'un historique initial de commandes test (Optionnel - pour peupler ton Dashboard au premier lancement)
INSERT INTO `commande` (`id_commande`, `reference_client`, `date_commande`, `total`, `statut`) VALUES
(1, 'Table 3', NOW() - INTERVAL 1 HOUR, 4000.00, 'PAYÉ'),
(2, 'Table 1', NOW(), 2500.00, 'EN ATTENTE');

INSERT INTO `ligne_commande` (`id_commande`, `id_produit`, `quantite`) VALUES
(1, 1, 1), -- 1 Chou (1500)
(1, 2, 1), -- 1 Alloco (1000)
(1, 1, 1), -- Un autre chou pour tester le cumul
(2, 2, 1), -- 1 Alloco (1000)
(2, 4, 3); -- 3 Bissap (1500)