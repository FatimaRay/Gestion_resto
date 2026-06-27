import os
import re
from flask import Flask, render_template, request, jsonify, redirect, url_for
import mysql.connector

app = Flask(__name__)

# Configuration de la connexion MySQL Workbench
db_config = {
    'host': 'localhost',
    'user': 'resto_user',
    'password': 'resto123',         
    'database': 'new_schema' 
}

def get_db_connection():
    return mysql.connector.connect(**db_config)

# 1. Affichage du menu interactif (Page d'accueil)
@app.route('/')
def index():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM produit")
    produits = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('index.html', produits=produits)

# 2, 3 & 4. Enregistrement commande, calcul automatique du total et mise à jour des stocks
@app.route('/passer_commande', methods=['POST'])
def passer_commande():
    data = request.json
    if not data:
        return jsonify({'error': 'Données de commande manquantes'}), 400
        
    reference_client = data.get('reference_client')
    panier = data.get('panier')
    
    if not reference_client or not panier:
        return jsonify({'error': 'Données de commande incomplètes'}), 400

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        # Étape A: Création initiale de la commande
        cursor.execute(
            "INSERT INTO commande (reference_client, date_commande, total, statut) VALUES (%s, NOW(), 0.00, 'EN ATTENTE')",
            (reference_client,)
        )
        id_commande = cursor.lastrowid
        total_facture = 0.0
        
        # Étape B: Parcourir le panier
        for article in panier:
            raw_id = article.get('id_produit') or article.get('id_Produit') or article.get('id')
            if raw_id is None or str(raw_id).strip() == '':
                continue 
                
            id_p = int(raw_id)
            qte = int(article.get('quantite', 1))
            
            # Récupération du prix
            cursor.execute("SELECT prix FROM produit WHERE id_produit = %s", (id_p,))
            prod = cursor.fetchone()
            
            if prod:
                # Nettoyage rigoureux du prix
                prix_brut = str(prod['prix'])
                prix_clean = re.sub(r'\D', '', prix_brut.split('.')[0])
                prix_unitaire = float(prix_clean) if prix_clean else 0.0
                
                total_facture += prix_unitaire * qte
                
                # Insertion de la liaison pour récupérer les menus pris plus tard
                cursor.execute(
                    "INSERT INTO ligne_commande (id_commande, id_produit, quantite) VALUES (%s, %s, %s)",
                    (id_commande, id_p, qte)
                )
                
                # Étape C : Soustraction des ingrédients
                cursor.execute("SELECT id_ingredient, quantite_requise FROM recette WHERE id_produit = %s", (id_p,))
                recettes = cursor.fetchall()
                for r in recettes:
                    qte_totale_a_retirer = float(r['quantite_requise']) * qte
                    cursor.execute(
                        "UPDATE ingredient SET quantite_stock = quantite_stock - %s WHERE id_ingredient = %s",
                        (qte_totale_a_retirer, r['id_ingredient'])
                    )

        # Étape D: Enregistrement final du montant associé calculé
        cursor.execute("UPDATE commande SET total = %s WHERE id_commande = %s", (total_facture, id_commande))
        conn.commit()
        return jsonify({'success': True, 'id_commande': id_commande, 'total': total_facture})
        
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# 5. Tableau de bord mis à jour avec la colonne des menus récupérés
@app.route('/dashboard')
def dashboard():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # La requête magique qui récupère les menus pris mis bout à bout
    query = """
        SELECT 
            c.id_commande, 
            c.reference_client, 
            c.date_commande, 
            c.statut,
            IFNULL(c.total, 0.00) as total,
            GROUP_CONCAT(CONCAT(p.nom, ' (x', lc.quantite, ')') SEPARATOR ', ') AS menus_pris
        FROM commande c
        LEFT JOIN ligne_commande lc ON c.id_commande = lc.id_commande
        LEFT JOIN produit p ON lc.id_produit = p.id_produit
        GROUP BY c.id_commande
        ORDER BY c.date_commande DESC
    """
    cursor.execute(query)
    commandes = cursor.fetchall()
    
    # Calcul des recettes du jour
    cursor.execute("SELECT SUM(total) as total FROM commande WHERE LOWER(statut) = 'payé' AND DATE(date_commande) = CURDATE()")
    res_recettes = cursor.fetchone()
    recettes_jour = res_recettes['total'] if res_recettes['total'] is not None else 0.00
    
    # État des stocks
    cursor.execute("SELECT * FROM ingredient")
    ingredients = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return render_template('dashboard.html', commandes=commandes, recettes_jour=recettes_jour, ingredients=ingredients)

@app.route('/modifier_statut/<int:id_commande>', methods=['POST'])
def modifier_statut(id_commande):
    nouveau_statut = request.form.get('statut')
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("UPDATE commande SET statut = %s WHERE id_commande = %s", (nouveau_statut, id_commande))
    conn.commit()
    cursor.close()
    conn.close()
    return redirect(url_for('dashboard'))

if __name__ == '__main__':
    app.run(debug=True)