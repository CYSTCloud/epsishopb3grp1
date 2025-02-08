import 'dart:convert';
import 'package:epsi_shop/bo/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';

/// Displays detailed information about a product
class DetailPage extends StatelessWidget {
  const DetailPage(this.productId, {super.key});
  
  final int productId;

  Future<Product> _fetchProduct() async {
    final response = await http.get(
      Uri.parse('https://fakestoreapi.com/products/$productId'),
    );

    if (response.statusCode == 200) {
      return Product.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Échec du chargement du produit');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Détail du produit"),
        actions: [
          CartIconWithBadge(),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _fetchProduct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ProductDetails(product: snapshot.data!);
          } else {
            return const Center(child: Text('Aucun produit trouvé'));
          }
        },
      ),
    );
  }
}

/// Displays the cart icon with the current number of items
class CartIconWithBadge extends StatelessWidget {
  const CartIconWithBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.go("/cart"),
      icon: Consumer<Cart>(
        builder: (context, cart, _) => Badge(
          label: Text(cart.getAll().length.toString()),
          child: const Icon(Icons.shopping_cart),
        ),
      ),
    );
  }
}

/// Displays the main product details including image, title, price, and add to cart button
class ProductDetails extends StatelessWidget {
  const ProductDetails({
    required this.product,
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductImage(imageUrl: product.image),
        ProductInfo(product: product),
        const Spacer(),
        AddToCartButton(product: product),
      ],
    );
  }
}

/// Displays the product image
class ProductImage extends StatelessWidget {
  const ProductImage({
    required this.imageUrl,
    super.key,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.contain,
    );
  }
}

/// Displays product information (title, price, description)
class ProductInfo extends StatelessWidget {
  const ProductInfo({
    required this.product,
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${product.price}€',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.description,
            style: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// Button to add the product to the cart
class AddToCartButton extends StatelessWidget {
  const AddToCartButton({
    required this.product,
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.read<Cart>().addItem(product);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produit ajouté au panier'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: const Text('Ajouter au panier'),
        ),
      ),
    );
  }
}
