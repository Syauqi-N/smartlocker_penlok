import 'package:flutter/material.dart';
import 'package:smartlocker/models/product.dart';
import 'package:smartlocker/models/store.dart';
import 'package:smartlocker/screens/buyer/product_detail_screen.dart';
import 'package:smartlocker/services/product_service.dart';
import 'package:smartlocker/services/store_service.dart';
import 'package:smartlocker/widgets/buyer_drawer.dart';
import 'package:smartlocker/widgets/product_card.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  final ProductService _productService = ProductService();
  final StoreService _storeService = StoreService.instance;

  List<Product> _products = const [];
  List<StoreSummary> _stores = const [];
  bool _isLoading = false;
  bool _storesLoading = false;
  String? _error;
  String? _storesError;
  int? _selectedStoreId;

  @override
  void initState() {
    super.initState();
    _loadStores();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products =
          await _productService.fetchProducts(storeId: _selectedStoreId);
      if (mounted) {
        setState(() => _products = products);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStores() async {
    setState(() {
      _storesLoading = true;
      _storesError = null;
    });
    try {
      final stores = await _storeService.fetchStores();
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _storesLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _storesLoading = false;
        _storesError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      drawer: const BuyerDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_error != null) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(child: Text(_error!)),
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStoreFilter(),
                const SizedBox(height: 12),
                if (_products.isEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: const Center(
                      child: Text('No products available right now.'),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStoreFilter() {
    if (_storesLoading) {
      return Row(
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Loading sellers...'),
        ],
      );
    }
    if (_storesError != null) {
      return Text(
        _storesError!,
        style: const TextStyle(color: Colors.red),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Seller',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int?>(
          initialValue: _selectedStoreId,
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('All Sellers'),
            ),
            ..._stores.map(
              (store) => DropdownMenuItem<int?>(
                value: store.id,
                child: Text(
                    '${store.name}${store.location != null ? ' • ${store.location}' : ''}'),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() => _selectedStoreId = value);
            _loadProducts();
          },
        ),
      ],
    );
  }
}
