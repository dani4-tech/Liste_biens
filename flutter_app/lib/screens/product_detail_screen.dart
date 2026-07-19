import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/product.dart';
import '../services/favorites_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final favorites = await FavoritesService.getFavorites();
    setState(() => _isFavorite = favorites.contains(widget.product.id));
  }

  Future<void> _toggleFavorite() async {
    final isNowFavorite = await FavoritesService.toggle(widget.product.id);
    setState(() => _isFavorite = isNowFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Image en plein écran derrière tout le reste
          Hero(
            tag: 'product-image-${product.id}',
            child: SizedBox(
              width: double.infinity,
              height: 340,
              child: Image.network(
                product.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF2F0F7),
                  child: const Icon(Icons.broken_image_outlined, size: 48, color: AppColors.textGrey),
                ),
              ),
            ),
          ),

          // Boutons flottants (retour / favori) par-dessus l'image
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.of(context).pop()),
                  _RoundIconButton(
                    icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    iconColor: _isFavorite ? AppColors.accent : AppColors.textDark,
                    onTap: _toggleFavorite,
                  ),
                ],
              ),
            ),
          ),

          // Panneau d'infos qui remonte par-dessus le bas de l'image
          Positioned(
            left: 0,
            right: 0,
            top: 280,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFFF2F0F7), borderRadius: BorderRadius.circular(10)),
                      child: Text(product.categorie,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(product.titre,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.2)),
                        ),
                        const SizedBox(width: 12),
                        Text('${product.prix.toStringAsFixed(2)} €',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 8),
                    Text(product.description, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textGrey)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _toggleFavorite,
                        icon: Icon(_isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
                        label: Text(_isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: iconColor ?? AppColors.textDark, size: 20),
        ),
      ),
    );
  }
}