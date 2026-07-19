from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import os

app = Flask(__name__)
CORS(app)

DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')

def load_json(filename):
    path = os.path.join(DATA_DIR, filename)
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

users = load_json('users.json')
ventes = load_json('ventes.json')

# --- Connexion ---
@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    user = next((u for u in users if u['email'] == email and u['password'] == password), None)

    if user:
        # On ne renvoie jamais le mot de passe au client
        safe_user = {k: v for k, v in user.items() if k != 'password'}
        return jsonify(safe_user), 200
    else:
        return jsonify({'error': 'Email ou mot de passe incorrect'}), 401

# --- Liste des produits ---
@app.route('/api/produits', methods=['GET'])
def get_produits():
    return jsonify(ventes), 200

# --- Détail d'un produit ---
@app.route('/api/produits/<int:produit_id>', methods=['GET'])
def get_produit(produit_id):
    produit = next((p for p in ventes if p['id'] == produit_id), None)
    if produit:
        return jsonify(produit), 200
    else:
        return jsonify({'error': 'Produit non trouvé'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)