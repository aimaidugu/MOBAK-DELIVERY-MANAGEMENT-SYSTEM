import 'package:delivery/itemorder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'providers.g.dart';

final db = FirebaseFirestore.instance;

String normalizeFuelType(String? value, {String defaultValue = 'petrol'}) {
  final normalized = (value ?? defaultValue).trim().toLowerCase();
  if (normalized == 'petrol' || normalized == 'diesel') {
    return normalized;
  }
  return defaultValue;
}

double normalizeCostValue(Object? value, {double defaultValue = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return defaultValue;
}

double calculateDeliveryFee(double distanceKm, double pricePerKm) {
  return distanceKm * pricePerKm;
}

double calculateOrderTotal({
  required double fuelCost,
  required double deliveryFee,
}) {
  return fuelCost + deliveryFee;
}

bool isPendingOrderStatus(String status) {
  return const {'awaiting', 'pending', 'awaiting_payment'}
      .contains(status.trim().toLowerCase());
}

bool matchesOrderStatusFilter(String status, String filter) {
  if (filter == 'all') return true;
  if (filter == 'pending') return isPendingOrderStatus(status);
  return status.trim().toLowerCase() == filter;
}

double readCostMapValue(Map<String, dynamic>? data,
    {double defaultValue = 0.0}) {
  if (data == null) return defaultValue;

  const candidateKeys = ['cost', 'Cost', 'price', 'Price', 'value', 'Value'];
  for (final key in candidateKeys) {
    final value = data[key];
    if (value != null) {
      return normalizeCostValue(value, defaultValue: defaultValue);
    }
  }

  return defaultValue;
}

Future<double> readFirestoreCost(
  List<String> paths, {
  double defaultValue = 0.0,
}) async {
  for (final path in paths) {
    try {
      final snapshot = await db.doc(path).get();
      if (snapshot.exists) {
        return readCostMapValue(snapshot.data(), defaultValue: defaultValue);
      }
    } catch (_) {
      // continue to the next fallback path
    }
  }
  return defaultValue;
}

@riverpod
Future<List<ItemOrder>> getAllOrders(Ref ref) async {
  return const [];
}

@riverpod
Future<void> addOrder(Ref ref, ItemOrder data) async {
  // Use the provided `id` as the document id to allow deterministic updates
  await db.collection('orders').doc(data.id).set(data.toMap());
  return;
}

@riverpod
Future<void> updateOrderStatus(Ref ref, String data, String id) async {
  // data => new status, id => order.id
  final query =
      await db.collection('orders').where('id', isEqualTo: id).limit(1).get();
  if (query.docs.isEmpty) {
    throw Exception('Order not found');
  }
  final docId = query.docs.first.id;
  await db.doc('orders/$docId').update({'status': data});
  return;
}

@riverpod
Future<void> updateCost(Ref ref, double newCost) async {
  final payload = {'cost': newCost, 'updatedAt': FieldValue.serverTimestamp()};
  await db.doc('costs/petrol').set(payload, SetOptions(merge: true));
  await db.doc('costs/oil').set(payload, SetOptions(merge: true));
  return;
}

@riverpod
Future<void> assignOrder(Ref ref, String id, String assignee) async {
  final query =
      await db.collection('orders').where('id', isEqualTo: id).limit(1).get();
  if (query.docs.isEmpty) {
    throw Exception('Order not found');
  }

  final docId = query.docs.first.id;
  await db.doc('orders/$docId').update({
    'assignedTo': assignee,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

@riverpod
Future<void> addNotification(
  Ref ref,
  String title,
  String message, {
  required String orderId,
  required String assignee,
}) async {
  await db.collection('notifications').add({
    'title': title,
    'message': message,
    'orderId': orderId,
    'assignee': assignee,
    'createdAt': FieldValue.serverTimestamp(),
    'read': false,
  });
}

@riverpod
Stream<List<Map<String, dynamic>>> notificationsStream(Ref ref) {
  return db
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList());
}

@riverpod
Future<void> updateDeliveryCost(Ref ref, double newCost) async {
  await db.doc('costs/delivery').set(
    {'cost': newCost, 'updatedAt': FieldValue.serverTimestamp()},
    SetOptions(merge: true),
  );
  return;
}

@riverpod
Future<void> updateDeliveryStatePrice(
  Ref ref,
  String state,
  double newCost,
) async {
  final cleanedState = state.trim();
  if (cleanedState.isEmpty) return;

  final docId =
      cleanedState.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  await db.doc('delivery_pricing/$docId').set(
    {
      'state': cleanedState,
      'price': newCost,
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
  return;
}

@riverpod
Future<void> updateDeliveryStatePerKm(
  Ref ref,
  String state,
  double perKm,
) async {
  final cleanedState = state.trim();
  if (cleanedState.isEmpty) return;

  final docId =
      cleanedState.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  await db.doc('delivery_pricing/$docId').set(
    {
      'state': cleanedState,
      'per_km': perKm,
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
  return;
}

Map<String, double> buildDeliveryStatePerKmMap(
    Iterable<Map<String, dynamic>> documents) {
  final perKm = <String, double>{};
  for (final data in documents) {
    final state = (data['state'] ?? '').toString().trim();
    if (state.isEmpty) continue;
    final value = normalizeCostValue(
        data['per_km'] ?? data['perKm'] ?? data['perKmRate'] ?? 0.0,
        defaultValue: 0.0);
    perKm[state] = value;
  }
  return perKm;
}

@riverpod
Future<Map<String, double>> getDeliveryStatePerKm(Ref ref) async {
  try {
    final snapshot = await db.collection('delivery_pricing').get();
    return buildDeliveryStatePerKmMap(snapshot.docs.map((d) => d.data()));
  } catch (_) {
    return {};
  }
}

Map<String, double> buildDeliveryStatePriceMap(
    Iterable<Map<String, dynamic>> documents) {
  final statePrices = <String, double>{};

  for (final data in documents) {
    final state = (data['state'] ?? '').toString().trim();
    if (state.isEmpty) continue;

    final value = normalizeCostValue(
      data['price'] ?? data['cost'] ?? data['amount'],
      defaultValue: 0.0,
    );
    statePrices[state] = value;
  }

  return statePrices;
}

@riverpod
Future<Map<String, double>> getDeliveryStatePrices(Ref ref) async {
  try {
    final snapshot = await db.collection('delivery_pricing').get();
    return buildDeliveryStatePriceMap(
      snapshot.docs.map((doc) => doc.data()),
    );
  } catch (_) {
    return {};
  }
}

@riverpod
Future<double> getCost(Ref ref) async {
  return readFirestoreCost(['costs/petrol', 'costs/oil']);
}

@riverpod
Future<double> getDeliveryCost(Ref ref) async {
  return readFirestoreCost(['costs/delivery']);
}

@riverpod
Future<double> getDieselCost(Ref ref) async {
  return readFirestoreCost(['costs/diesel', 'costs/oil']);
}

@riverpod
Future<(double, double, double)> getCosts(Ref ref) async {
  return (
    await ref.watch(getCostProvider.future),
    await ref.watch(getDieselCostProvider.future),
    await ref.watch(getDeliveryCostProvider.future),
  );
}

final getAllOrdersStreamProvider = StreamProvider<List<ItemOrder>>((ref) {
  return db.collection('orders').snapshots().map((snap) {
    return snap.docs.map((d) => ItemOrder.fromMap(d.data())).toList();
  });
});
