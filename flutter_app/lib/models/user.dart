class User {
  final int id;
  final String email;
  final String nom;
  final String prenom;

  User({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
    );
  }

  // Pour sauvegarder l'utilisateur en local (SharedPreferences ne stocke que du texte)
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nom': nom,
    'prenom': prenom,
  };
}