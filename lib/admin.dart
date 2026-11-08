import 'package:delivery/constants.dart';
import 'package:delivery/itemorder.dart';
import 'package:delivery/main.dart';
import 'package:delivery/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminView extends ConsumerWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Not authenticated')),
        persistentFooterButtons: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainAp()),
                  (route) => false);
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60)),
            child: const Text("Back"),
          )
        ],
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.doc('admins/${user.uid}').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        if (!snapshot.hasData || !(snapshot.data as DocumentSnapshot).exists) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('You are not authorized as admin')),
            persistentFooterButtons: [
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainAp()),
                      (route) => false);
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60)),
                child: const Text("Back"),
              )
            ],
          );
        }

        // Authorized admin — render admin UI
        final statePricesAsync = ref.watch(getDeliveryStatePricesProvider);

        return Scaffold(
          appBar: AppBar(),
          persistentFooterButtons: [
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainAp()),
                    (route) => false);
              },
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60)),
              child: const Text("Logout"),
            )
          ],
          body: DecoratedBox(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/sendy-truck.jpg"),
                    fit: BoxFit.cover)),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: statePricesAsync.when(
                    data: (statePrices) {
                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance.collection('delivery_pricing').get(),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator.adaptive());
                          }
                          if (!snap.hasData) {
                            return const Center(child: Text('Failed to load per-km data'));
                          }
                          final perKmMap = <String, double>{};
                          for (final doc in snap.data!.docs) {
                            final d = doc.data() as Map<String, dynamic>;
                            final state = (d['state'] ?? '').toString().trim();
                            if (state.isEmpty) continue;
                            final v = normalizeCostValue(d['per_km'] ?? d['perKm'] ?? 0.0);
                            perKmMap[state] = v;
                          }
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                  child: Card(
                                    color: Colors.blueAccent,
                                    child: ListTile(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            actions: [
                                              TextButton(
                                                onPressed: () async {
                                                  await ref.watch(updateCostProvider(ref.watch(_newcost).value).future);
                                                  if (!context.mounted) return;
                                                  NotificationService.showNotificationToast(
                                                    context,
                                                    "Updated cost of oil per Litre",
                                                    "cost updated",
                                                    NotificationTypes.good,
                                                  );
                                                },
                                                child: Text("Save Naira ${ref.watch(_newcost)}"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  if (!context.mounted) return;
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("cancel"),
                                              ),
                                            ],
                                            content: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                onChanged: (newcost) {
                                                  ref.read(_newcost).value = double.tryParse(newcost) ?? 0.0;
                                                },
                                                decoration: InputDecoration(
                                                  hintText: "Enter new cost per litre",
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      title: const Text("Update Oil cost"),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                  child: Card(
                                    color: Colors.blueAccent,
                                    child: ListTile(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            actions: [
                                              TextButton(
                                                onPressed: () async {
                                                  await ref.watch(updateDeliveryCostProvider(ref.watch(_newcostKM).value).future);
                                                  if (!context.mounted) return;
                                                  NotificationService.showNotificationToast(
                                                    context,
                                                    "Updated cost of delivery per km",
                                                    "cost updated",
                                                    NotificationTypes.good,
                                                  );
                                                },
                                                child: Text("Save Naira ${ref.watch(_newcostKM)}"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  if (!context.mounted) return;
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("cancel"),
                                              ),
                                            ],
                                            content: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                onChanged: (newcost) {
                                                  ref.read(_newcostKM).value = double.tryParse(newcost) ?? 0.0;
                                                },
                                                decoration: InputDecoration(
                                                  hintText: "Enter new cost per km",
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      title: const Text("Update Delivery cost per km"),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Delivery pricing by state',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 12),
                                          ...nigerianStates.map((state) {
                                            final currentPrice = statePrices[state] ?? 0.0;
                                              final currentPerKm = perKmMap[state] ?? 0.0;
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      state,
                                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 110,
                                                    child: TextFormField(
                                                      initialValue: currentPrice.toStringAsFixed(2),
                                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                      decoration: InputDecoration(
                                                        labelText: '₦',
                                                        isDense: true,
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      onFieldSubmitted: (value) async {
                                                        final parsed = double.tryParse(value) ?? 0.0;
                                                        await ref.read(updateDeliveryStatePriceProvider(state, parsed).future);
                                                        if (!context.mounted) return;
                                                        NotificationService.showNotificationToast(
                                                          context,
                                                          'Updated delivery price for $state',
                                                          'State price saved',
                                                          NotificationTypes.good,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  SizedBox(
                                                    width: 120,
                                                    child: TextFormField(
                                                      initialValue: currentPerKm.toStringAsFixed(2),
                                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                      decoration: InputDecoration(
                                                        labelText: '₦/km',
                                                        isDense: true,
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      onFieldSubmitted: (value) async {
                                                        final parsed = double.tryParse(value) ?? 0.0;
                                                        final docId = state.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
                                                        await FirebaseFirestore.instance.doc('delivery_pricing/$docId').set({
                                                          'state': state,
                                                          'per_km': parsed,
                                                          'updatedAt': FieldValue.serverTimestamp(),
                                                        }, SetOptions(merge: true));
                                                        if (!context.mounted) return;
                                                        NotificationService.showNotificationToast(
                                                          context,
                                                          'Updated per-km price for $state',
                                                          'State per-km saved',
                                                          NotificationTypes.good,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                  child: Card(
                                    color: Colors.blueAccent,
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                          return const _AllOrders();
                                        }));
                                      },
                                      title: const Text("View all orders"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                    error: (error, stack) => Center(child: Text('Unable to load states: $error')),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final _newcost = Provider<ValueNotifier<double>>((ref) {
  final vn = ValueNotifier<double>(0.0);
  ref.onDispose(vn.dispose);
  return vn;
});

final _newcostKM = Provider<ValueNotifier<double>>((ref) {
  final vn = ValueNotifier<double>(0.0);
  ref.onDispose(vn.dispose);
  return vn;
});

class _AllOrders extends ConsumerWidget {
  const _AllOrders();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(),
        body: ref.watch(getAllOrdersStreamProvider).when(data: (orders) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ...orders.map((e) {
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                          child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => _OrderDetails(order: e)));
                        },
                        subtitle: Text(e.totalAmount.toString()),
                        trailing: Text(e.dateTime),
                        title: Text(e.requestName),
                      )));
                })
              ],
            ),
          );
        }, error: (er, st) {
          debugPrintStack(stackTrace: st);
          return const Center(child: Text('Failed to load'));
        }, loading: () {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }));
  }
}

class _OrderDetails extends ConsumerWidget {
  const _OrderDetails({required this.order});
  final ItemOrder order;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(),
        persistentFooterButtons: [
          ElevatedButton(
              onPressed: () async {
              await ref
                .watch(updateOrderStatusProvider("delivered", order.id).future);
              if (!context.mounted) return;
              NotificationService.showNotificationToast(
                  context, "Order Updated", "order ", NotificationTypes.good);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 65)),
            child: const Text("mark as delivered"),
          )
        ],
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                child: ListTile(
              title: Text(order.dateTime),
              subtitle: const Text("Date"),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                child: ListTile(
              title: Text(order.deliveryAddress),
              subtitle: const Text("Delivery Address"),
            )),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  child: ListTile(
                      title: Text(order.phoneNumber),
                      subtitle: const Text("Delivery number")))),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  child: ListTile(
                      title: Text(order.requestName),
                      subtitle: const Text("Name")))),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  child: ListTile(
                      title: Text(order.totalAmount),
                      subtitle: const Text("amount")))),
          if (order.quantityOil.isNotEmpty)
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                    child: ListTile(
                        title: Text(order.quantityOil),
                        subtitle: const Text("amount of oil")))),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  child: ListTile(
                      title: Text(order.status),
                      subtitle: const Text("Status"))))
        ]))));
  }
}
