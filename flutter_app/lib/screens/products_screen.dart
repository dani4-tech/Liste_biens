import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../services/favorites_service.dart';
import 'product_detail_screen.dart';
import 'login_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<Product>> _futureProducts;
  User? _currentUser;
  String _selectedCategory = 'Toutes';
  Set<int> _favoriteIds = {};
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _futureProducts = ApiService.fetchProducts();
    _loadUser();
    _loadFavorites();
  }

  Future<void> _loadUser() async {
    final user = await SessionService.getUser();
    setState(() => _currentUser = user);
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesService.getFavorites();
    setState(() => _favoriteIds = favorites);
  }

  Future<void> _toggleFavorite(int productId) async {
    final isNowFavorite = await FavoritesService.toggle(productId);
    setState(() {
      if (isNowFavorite) {
        _favoriteIds.add(productId);
      } else {
        _favoriteIds.remove(productId);
      }
    });
  }

  Future<void> _handleLogout() async {
    await SessionService.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentUser != null
            ? RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
            children: [
              const TextSpan(text: 'Bonjour '),
              TextSpan(text: _currentUser!.prenom, style: const TextStyle(color: AppColors.primary)),
            ],
          ),
        )
            : const Text('Ventes Privées'),
        actions: [
          IconButton(
            icon: Icon(_showOnlyFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _showOnlyFavorites ? AppColors.accent : AppColors.textDark),
            tooltip: 'Afficher les favoris',
            onPressed: () => setState(() => _showOnlyFavorites = !_showOnlyFavorites),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Se déconnecter',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingGrid();
          }
          if (snapshot.hasError) {
            return const _MessageState(
              icon: Icons.wifi_off_rounded,
              title: 'Connexion impossible',
              subtitle: 'Vérifie que le serveur est démarré et accessible.',
            );
          }

          final allProducts = snapshot.data!;
          final categories = ['Toutes', ...allProducts.map((p) => p.categorie).toSet()];

          var filtered = _selectedCategory == 'Toutes'
              ? allProducts
              : allProducts.where((p) => p.categorie == _selectedCategory).toList();

          if (_showOnlyFavorites) {
            filtered = filtered.where((p) => _favoriteIds.contains(p.id)).toList();
          }

          return Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: categories.map((cat) {
                    final selected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? _MessageState(
                  icon: _showOnlyFavorites ? Icons.favorite_border_rounded : Icons.search_off_rounded,
                  title: _showOnlyFavorites ? 'Aucun favori' : 'Aucun produit',
                  subtitle: _showOnlyFavorites
                      ? 'Ajoute des articles en tapant sur le cœur.'
                      : 'Essaie une autre catégorie.',
                )
                    : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final product = filtered[i];
                    return _ProductCard(
                      product: product,
                      isFavorite: _favoriteIds.contains(product.id),
                      onToggleFavorite: () => _toggleFavorite(product.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _ProductCard({required this.product, required this.isFavorite, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondary) => ProductDetailScreen(product: product),
          transitionsBuilder: (context, animation, secondary, child) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product-image-${product.id}',
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF2F0F7),
                        child: const Icon(Icons.broken_image_outlined, color: AppColors.textGrey),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      shadowColor: Colors.black26,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onToggleFavorite,
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? AppColors.accent : AppColors.textGrey,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.textDark.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                      child: Text(product.categorie, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.titre, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text('${product.prix.toStringAsFixed(2)} €',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Squelette de chargement (shimmer simplifié) affiché pendant l'appel API.
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (context, i) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.4, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFFEDEBF3), borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MessageState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: const Color(0xFFF2F0F7), borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, color: AppColors.textGrey, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}