import 'package:flutter/material.dart';

void main() => runApp(const QuickDeliveryApp());

class QuickDeliveryApp extends StatelessWidget {
  const QuickDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Quick Delivery',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16834A)),
      scaffoldBackgroundColor: const Color(0xFFF7F9F6),
    ),
    home: const GroceryHomePage(),
  );
}

class GroceryProduct {
  final String name, unit, category, emoji;
  final int price;
  const GroceryProduct(this.name, this.unit, this.category, this.emoji, this.price);
}

const products = <GroceryProduct>[
  GroceryProduct('Fresh Apples', '1 kg', 'Fruits', '🍎', 140),
  GroceryProduct('Bananas', '6 pieces', 'Fruits', '🍌', 45),
  GroceryProduct('Tomatoes', '1 kg', 'Vegetables', '🍅', 35),
  GroceryProduct('Potatoes', '1 kg', 'Vegetables', '🥔', 30),
  GroceryProduct('Full Cream Milk', '1 litre', 'Dairy', '🥛', 68),
  GroceryProduct('Brown Bread', '1 pack', 'Bakery', '🍞', 50),
  GroceryProduct('Basmati Rice', '1 kg', 'Staples', '🍚', 110),
  GroceryProduct('Orange Juice', '1 litre', 'Drinks', '🧃', 95),
];

class GroceryHomePage extends StatefulWidget {
  const GroceryHomePage({super.key});
  @override
  State<GroceryHomePage> createState() => _GroceryHomePageState();
}

class _GroceryHomePageState extends State<GroceryHomePage> {
  final searchController = TextEditingController();
  final Map<GroceryProduct, int> cart = {};
  String category = 'All';
  final categories = const ['All', 'Fruits', 'Vegetables', 'Dairy', 'Bakery', 'Staples', 'Drinks'];

  int get itemCount => cart.values.fold(0, (a, b) => a + b);
  int get total => cart.entries.fold(0, (a, e) => a + e.key.price * e.value);

  List<GroceryProduct> get visibleProducts => products.where((p) {
    final matchesCategory = category == 'All' || p.category == category;
    final q = searchController.text.trim().toLowerCase();
    return matchesCategory && (q.isEmpty || p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q));
  }).toList();

  void changeQty(GroceryProduct p, int delta) {
    setState(() {
      final next = (cart[p] ?? 0) + delta;
      if (next <= 0) {
        cart.remove(p);
      } else {
        cart[p] = next;
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: const Row(children: [
        Icon(Icons.shopping_basket_rounded, color: Color(0xFF16834A)),
        SizedBox(width: 8),
        Text('Quick Delivery', style: TextStyle(fontWeight: FontWeight.w800)),
      ]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(child: Badge(
            isLabelVisible: itemCount > 0,
            label: Text('$itemCount'),
            child: const Icon(Icons.shopping_cart_outlined),
          )),
        ),
      ],
    ),
    body: SafeArea(child: CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        child: Row(children: const [
          Icon(Icons.location_on_outlined, color: Color(0xFF16834A)),
          SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DELIVER TO', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
            Text('Choose your delivery address', style: TextStyle(fontWeight: FontWeight.w600)),
          ])),
        ]),
      )),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search fruits, vegetables, milk...',
            prefixIcon: const Icon(Icons.search),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
      )),
      SliverToBoxAdapter(child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [Color(0xFF126B3C), Color(0xFF25A45D)]),
        ),
        child: const Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Fresh groceries,', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
            Text('delivered to your door', style: TextStyle(color: Colors.white, fontSize: 17)),
            SizedBox(height: 8),
            Text('30–60 minute delivery target', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          Text('🛵', style: TextStyle(fontSize: 48)),
        ]),
      )),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text('Shop by category', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      )),
      SliverToBoxAdapter(child: SizedBox(height: 42, child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => ChoiceChip(
          label: Text(categories[i]),
          selected: category == categories[i],
          onSelected: (_) => setState(() => category = categories[i]),
        ),
      ))),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text('Popular groceries', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      )),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (_, i) => productCard(visibleProducts[i]),
            childCount: visibleProducts.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .78,
          ),
        ),
      ),
    ])),
    bottomNavigationBar: itemCount == 0 ? null : SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: FilledButton(
        onPressed: openCart,
        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
        child: Text('View cart • $itemCount items • ₹$total'),
      ),
    ),
  );

  Widget productCard(GroceryProduct p) {
    final qty = cart[p] ?? 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9EEE9))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 58)))),
        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(p.unit, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Text('₹${p.price}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
          if (qty == 0)
            IconButton.filled(onPressed: () => changeQty(p, 1), icon: const Icon(Icons.add, size: 18), visualDensity: VisualDensity.compact)
          else
            Row(children: [
              IconButton(onPressed: () => changeQty(p, -1), icon: const Icon(Icons.remove, size: 17), visualDensity: VisualDensity.compact),
              Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => changeQty(p, 1), icon: const Icon(Icons.add, size: 17), visualDensity: VisualDensity.compact),
            ]),
        ]),
      ]),
    );
  }

  void openCart() {
    showModalBottomSheet(context: context, showDragHandle: true, isScrollControlled: true, builder: (ctx) => StatefulBuilder(
      builder: (ctx, refresh) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your cart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (cart.isEmpty) const Text('Your cart is empty.')
          else ...[
            ...cart.entries.map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(e.key.emoji, style: const TextStyle(fontSize: 26)),
              title: Text(e.key.name),
              subtitle: Text('₹${e.key.price} × ${e.value}'),
              trailing: Text('₹${e.key.price * e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
            )),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('₹$total', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ]),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkout and payments are coming in the next stage.')));
              },
              child: const Text('Continue to checkout'),
            )),
          ],
        ]),
      ),
    ));
  }
}
