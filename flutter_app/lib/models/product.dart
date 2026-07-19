class Product {
  final int id;
  final String image;
  final String titre;
  final String description;
  final String categorie;
  final double prix;

  Product({
    required this.id,
    required this.image,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.prix,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      image: json['image'],
      titre: json['titre'],
      description: json['description'],
      categorie: json['categorie'],
      prix: (json['prix'] as num).toDouble(),
    );
  }
}