import 'dart:convert';

import 'package:epsi_shop/bo/product.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class ListProductPage extends StatelessWidget {
  const ListProductPage({super.key});

  Future<List<Product>> getProducts() async {
    Response res = await get(Uri.parse("https://fakestoreapi.com/products"));
    if (res.statusCode == 200) {
      List<dynamic> listMapProducts = jsonDecode(res.body);
      return listMapProducts.map((lm) => Product.fromMap(lm)).toList();
    }
    return Future.error("Erreur de téléchargement");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('EPSI Shop'),
          actions: [
            Consumer<Cart>(
              builder: (context, cart, child) {
                return Row(
                  children: [
                    if (!cart.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Text(
                          'Total: ${cart.totalWithVat.toStringAsFixed(2)}€',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    IconButton(
                      onPressed: () => context.go("/cart"),
                      icon: Badge(
                        label: Text(cart.getAll().length.toString()),
                        child: const Icon(Icons.shopping_cart),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Product>>(
            future: getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                final listProducts = snapshot.data!;
                return ListViewProducts(listProducts: listProducts);
              } else {
                return const Center(child: Text("Erreur de chargement"));
              }
            }));
  }
}

class ListViewProducts extends StatelessWidget {
  const ListViewProducts({
    super.key,
    required this.listProducts,
  });

  final List<Product> listProducts;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listProducts.length,
      itemBuilder: (ctx, index) {
        final product = listProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: () => ctx.go("/detail/${product.id}"),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Image.network(
                    product.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: Theme.of(ctx).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.price}€',
                          style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                                color: Theme.of(ctx).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<Cart>(
                    builder: (context, cart, child) {
                      final isInCart = cart.items.containsKey(product.id);
                      return Row(
                        children: [
                          if (isInCart)
                            IconButton(
                              icon: const Icon(Icons.remove_shopping_cart),
                              color: Colors.red,
                              onPressed: () => cart.removeItem(product.id),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () {
                                cart.addItem(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Produit ajouté au panier'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
