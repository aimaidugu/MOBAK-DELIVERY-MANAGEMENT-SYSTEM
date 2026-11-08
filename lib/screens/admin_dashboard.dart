import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/constants.dart';
import 'package:delivery/reporting.dart';
import 'package:delivery/ui/components.dart';
import 'package:delivery/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery/providers.dart';
import 'package:delivery/itemorder.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  String _statusFilter = 'all';
  String _fuelFilter = 'all';
  String _search = '';
  String _selectedSection = 'Overview';
  final Set<String> _selectedOrderIds = <String>{};

  static const List<String> _assignees = [
    'Unassigned',
    'Dispatch',
    'Warehouse',
    'Fleet Ops',
    'Customer Care',
  ];

  List<ItemOrder> _applyFilters(List<ItemOrder> list) {
    Iterable<ItemOrder> filtered = list;
    if (_statusFilter != 'all') {
      filtered = filtered.where(
        (order) => matchesOrderStatusFilter(order.status, _statusFilter),
      );
    }
    if (_fuelFilter != 'all') {
      filtered = filtered
          .where((o) => normalizeFuelCategory(o.deliveryType) == _fuelFilter);
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      filtered = filtered.where((o) =>
          o.requestName.toLowerCase().contains(q) ||
          o.id.toLowerCase().contains(q) ||
          o.phoneNumber.toLowerCase().contains(q));
    }
    return filtered.toList();
  }

  Future<void> _assignOrder(
      BuildContext context, ItemOrder order, String? assignee) async {
    if (assignee == null) return;

    final value = assignee == 'Unassigned' ? '' : assignee;
    try {
      await ref.read(assignOrderProvider(order.id, value).future);
      await ref.read(
        addNotificationProvider(
          'Order assigned',
          'Order ${order.id} assigned to ${value.isEmpty ? 'Unassigned' : value}',
          orderId: order.id,
          assignee: value,
        ).future,
      );
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value.isEmpty
              ? 'Assignment cleared'
              : 'Order assigned to $value'),
        ),
      );
    } catch (error) {
      if (!mounted || !context.mounted) return;
      NotificationService.showNotificationToast(
        context,
        'Unable to assign order: $error',
        'Assignment failed',
        NotificationTypes.error,
      );
    }
  }

  Future<void> _updateOrderStatusWithNotification(
    BuildContext context,
    ItemOrder order,
    String status,
    String message,
  ) async {
    try {
      await ref.read(updateOrderStatusProvider(status, order.id).future);
      await ref.read(
        addNotificationProvider(
          'Order status updated',
          'Order ${order.id}: $message',
          orderId: order.id,
          assignee: order.assignedTo,
        ).future,
      );
      if (!mounted || !context.mounted) return;
      NotificationService.showNotificationToast(
        context,
        message,
        'Order updated',
        NotificationTypes.good,
      );
    } catch (error) {
      if (!mounted || !context.mounted) return;
      NotificationService.showNotificationToast(
        context,
        'Unable to update order: $error',
        'Update failed',
        NotificationTypes.error,
      );
    }
  }

  Future<void> _bulkUpdateSelectedStatus(
    BuildContext context,
    List<ItemOrder> orders,
    String status,
  ) async {
    if (_selectedOrderIds.isEmpty) return;

    final selectedOrders =
        orders.where((order) => _selectedOrderIds.contains(order.id)).toList();
    if (selectedOrders.isEmpty) return;

    try {
      for (final order in selectedOrders) {
        await ref.read(updateOrderStatusProvider(status, order.id).future);
        await ref.read(
          addNotificationProvider(
            'Order status updated',
            'Order ${order.id}: marked as ${status.replaceAll('_', ' ')}.',
            orderId: order.id,
            assignee: order.assignedTo,
          ).future,
        );
      }

      if (!mounted || !context.mounted) return;
      setState(() => _selectedOrderIds.clear());
      NotificationService.showNotificationToast(
        context,
        'Updated ${selectedOrders.length} order(s) to ${status.replaceAll('_', ' ')}.',
        'Bulk update complete',
        NotificationTypes.good,
      );
    } catch (error) {
      if (!mounted || !context.mounted) return;
      NotificationService.showNotificationToast(
        context,
        'Unable to bulk update: $error',
        'Bulk update failed',
        NotificationTypes.error,
      );
    }
  }

  void _showOrderDetails(BuildContext context, ItemOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(order.requestName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Order ID', order.id),
              _detailRow('Status', order.status),
              _detailRow('Phone', order.phoneNumber),
              _detailRow('Delivery Type', order.deliveryType),
              _detailRow('Address', order.deliveryAddress),
              _detailRow('Destination', order.destinationAddress),
              _detailRow('Assigned to',
                  order.assignedTo.isEmpty ? 'Unassigned' : order.assignedTo),
              _detailRow('Total', order.totalAmount),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (order.status != 'dispatched')
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateOrderStatusWithNotification(
                  context,
                  order,
                  'dispatched',
                  'Order marked as dispatched.',
                );
              },
              child: const Text('Mark dispatched'),
            ),
          if (order.status != 'payment_confirmed')
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateOrderStatusWithNotification(
                  context,
                  order,
                  'payment_confirmed',
                  'Payment confirmed for order.',
                );
              },
              child: const Text('Mark payment confirmed'),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value.isEmpty ? '—' : value),
          ],
        ),
      ),
    );
  }

  // Summary pill removed — operations summary feature intentionally disabled.

  Color _statusColor(String status) {
    switch (status) {
      case 'payment_confirmed':
      case 'delivered':
        return AppColors.success;
      case 'dispatched':
      case 'in_transit':
        return AppColors.info;
      case 'awaiting_payment':
      case 'awaiting':
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'awaiting_payment':
        return 'Awaiting Payment';
      case 'awaiting':
      case 'pending':
        return 'Pending';
      case 'dispatched':
        return 'Dispatched';
      case 'in_transit':
        return 'In Transit';
      case 'payment_confirmed':
        return 'Payment Confirmed';
      case 'delivered':
        return 'Delivered';
      default:
        return status.isEmpty ? 'New' : status;
    }
  }

  List<ItemOrder> _sortedOrders(List<ItemOrder> list) {
    final copy = List<ItemOrder>.from(list);
    copy.sort((a, b) {
      final aDate = DateTime.tryParse(a.dateTime) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse(b.dateTime) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return copy;
  }

  Future<void> _updateCostValue(
    BuildContext context, {
    required String field,
    required double currentValue,
  }) async {
    final controller =
        TextEditingController(text: currentValue.toStringAsFixed(2));
    final titleMap = {
      'petrol': 'Update petrol price',
      'diesel': 'Update diesel price',
      'delivery': 'Update delivery fee',
    };
    final labelMap = {
      'petrol': 'Petrol price / litre',
      'diesel': 'Diesel price / litre',
      'delivery': 'Delivery fee / km',
    };

    final nextValue = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(titleMap[field] ?? 'Update fuel pricing'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: labelMap[field] ?? 'Price',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed == null) {
                Navigator.of(dialogContext).pop();
                return;
              }
              Navigator.of(dialogContext).pop(parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (nextValue == null || !mounted || !context.mounted) return;

    try {
      if (field == 'petrol') {
        final payload = {
          'cost': nextValue,
          'updatedAt': FieldValue.serverTimestamp()
        };
        await db.doc('costs/petrol').set(payload, SetOptions(merge: true));
        await db.doc('costs/oil').set(payload, SetOptions(merge: true));
        ref.invalidate(getCostProvider);
      } else if (field == 'diesel') {
        final payload = {
          'cost': nextValue,
          'updatedAt': FieldValue.serverTimestamp()
        };
        await db.doc('costs/diesel').set(payload, SetOptions(merge: true));
        await db.doc('costs/oil').set(payload, SetOptions(merge: true));
        ref.invalidate(getDieselCostProvider);
      } else {
        await ref.read(updateDeliveryCostProvider(nextValue).future);
        ref.invalidate(getDeliveryCostProvider);
      }
      ref.invalidate(getCostsProvider);
      if (!mounted || !context.mounted) return;
      NotificationService.showNotificationToast(
        context,
        field == 'petrol'
            ? 'Petrol price updated successfully.'
            : field == 'diesel'
                ? 'Diesel price updated successfully.'
                : 'Delivery fee updated successfully.',
        'cost updated',
        NotificationTypes.good,
      );
    } catch (error) {
      if (!mounted || !context.mounted) return;
      NotificationService.showNotificationToast(
        context,
        'Unable to update cost: $error',
        'Cost update failed',
        NotificationTypes.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(getAllOrdersStreamProvider);
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final costsAsync = ref.watch(getCostsProvider);

    return AppScaffold(
      title: 'Mobak Petrol Supply & Logistics Dashboard',
      selectedSection: _selectedSection,
      onSectionSelected: (section) =>
          setState(() => _selectedSection = section),
      child: ordersAsync.when(
        data: (orders) {
          final pending =
              orders.where((o) => isPendingOrderStatus(o.status)).length;
          final delivered = orders.where((o) => o.status == 'delivered').length;

          final filtered = _sortedOrders(_applyFilters(orders));
          // Compute only values used by remaining dashboard widgets.

          return costsAsync.when(
            data: (costs) {
              // Fuel stock and reconciliation features removed for final-year project simplification.
              final showOverview = _selectedSection == 'Overview';
              final showOrders = _selectedSection == 'Orders';
              final showCosts = _selectedSection == 'Costs';
              final showNotifications = _selectedSection == 'Notifications';

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showOverview || showCosts) ...[
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: 180,
                                child: KPICard(
                                  title: 'Pending Orders',
                                  value: pending.toString(),
                                  color: AppColors.warning,
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: KPICard(
                                  title: 'Delivered',
                                  value: delivered.toString(),
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (showOverview || showCosts)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: 220,
                                    child: GestureDetector(
                                      onTap: () => _updateCostValue(context,
                                          field: 'petrol',
                                          currentValue: costs.$1),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Petrol price',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₦${costs.$1.toStringAsFixed(2)} / litre',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    child: GestureDetector(
                                      onTap: () => _updateCostValue(context,
                                          field: 'diesel',
                                          currentValue: costs.$2),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Diesel price',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₦${costs.$2.toStringAsFixed(2)} / litre',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    child: GestureDetector(
                                      onTap: () => _updateCostValue(context,
                                          field: 'delivery',
                                          currentValue: costs.$3),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Delivery fee',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₦${costs.$3.toStringAsFixed(2)} / km',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (showOverview || showOrders) ...[
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 260,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                          hintText:
                                              'Search by ID, name, phone'),
                                      onChanged: (v) =>
                                          setState(() => _search = v),
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: _statusFilter,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'all',
                                          child: Text('All status')),
                                      DropdownMenuItem(
                                          value: 'pending',
                                          child: Text('Pending')),
                                      DropdownMenuItem(
                                          value: 'awaiting_payment',
                                          child: Text('Awaiting Payment')),
                                      DropdownMenuItem(
                                          value: 'dispatched',
                                          child: Text('Dispatched')),
                                      DropdownMenuItem(
                                          value: 'payment_confirmed',
                                          child: Text('Payment Confirmed')),
                                      DropdownMenuItem(
                                          value: 'delivered',
                                          child: Text('Delivered')),
                                    ],
                                    onChanged: (v) => setState(
                                        () => _statusFilter = v ?? 'all'),
                                  ),
                                  DropdownButton<String>(
                                    value: _fuelFilter,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'all',
                                          child: Text('All fuel')),
                                      DropdownMenuItem(
                                          value: 'petrol',
                                          child: Text('Petrol')),
                                      DropdownMenuItem(
                                          value: 'diesel',
                                          child: Text('Diesel')),
                                    ],
                                    onChanged: (v) => setState(
                                        () => _fuelFilter = v ?? 'all'),
                                  ),
                                  ElevatedButton(
                                      onPressed: () => setState(() {}),
                                      child: const Text('Apply')),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final csv = buildOrderCsvReport(filtered);
                                      await Clipboard.setData(
                                          ClipboardData(text: csv));
                                      if (!mounted || !context.mounted) return;
                                      NotificationService.showNotificationToast(
                                        context,
                                        'Order report copied to clipboard as CSV.',
                                        'Report ready',
                                        NotificationTypes.good,
                                      );
                                    },
                                    icon: const Icon(Icons.download_outlined),
                                    label: const Text('Export CSV'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (showOverview) ...[
                          // Operations summary removed as requested.
                          const SizedBox(height: 12),
                          // Daily sales trend removed per request.
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Fuel stock position removed.
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_selectedOrderIds.length ==
                                            filtered.length) {
                                          _selectedOrderIds.clear();
                                        } else {
                                          _selectedOrderIds.clear();
                                          for (final order in filtered) {
                                            _selectedOrderIds.add(order.id);
                                          }
                                        }
                                      });
                                    },
                                    child: Text(_selectedOrderIds.length ==
                                            filtered.length
                                        ? 'Clear visible'
                                        : 'Select visible'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => _bulkUpdateSelectedStatus(
                                        context, orders, 'dispatched'),
                                    child: const Text('Mark dispatched'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => _bulkUpdateSelectedStatus(
                                        context, orders, 'payment_confirmed'),
                                    child: const Text('Mark payment confirmed'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => setState(
                                        () => _selectedOrderIds.clear()),
                                    child: const Text('Clear'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (showOverview ||
                            showOrders ||
                            showNotifications) ...[
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final useSideBySide = constraints.maxWidth >= 900;
                              if (!useSideBySide) {
                                return Column(
                                  children: [
                                    if (showOverview || showOrders)
                                      Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Recent Fuel Orders',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                const SizedBox(height: 12),
                                                if (filtered.isEmpty)
                                                  const Center(
                                                      child: Text(
                                                          'No orders found'))
                                                else
                                                  ListView.separated(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount: filtered.length,
                                                    separatorBuilder: (_, __) =>
                                                        const Divider(
                                                            height: 1),
                                                    itemBuilder: (context, i) {
                                                      final order = filtered[i];
                                                      final rawAssignedTo =
                                                          order.assignedTo
                                                              .trim();
                                                      final displayValue =
                                                          _assignees.contains(
                                                                  rawAssignedTo)
                                                              ? rawAssignedTo
                                                              : 'Unassigned';

                                                      return InkWell(
                                                        onTap: () =>
                                                            _showOrderDetails(
                                                                context, order),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      8.0),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Checkbox(
                                                                value: _selectedOrderIds
                                                                    .contains(
                                                                        order
                                                                            .id),
                                                                onChanged:
                                                                    (selected) {
                                                                  setState(() {
                                                                    if (selected ==
                                                                        true) {
                                                                      _selectedOrderIds
                                                                          .add(order
                                                                              .id);
                                                                    } else {
                                                                      _selectedOrderIds
                                                                          .remove(
                                                                              order.id);
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                            child:
                                                                                Text(order.requestName)),
                                                                        const SizedBox(
                                                                            width:
                                                                                8),
                                                                        Container(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 8,
                                                                              vertical: 4),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                _statusColor(order.status).withValues(alpha: 0.12),
                                                                            borderRadius:
                                                                                BorderRadius.circular(999),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            _statusLabel(order.status),
                                                                            style:
                                                                                TextStyle(
                                                                              color: _statusColor(order.status),
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 11,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            4),
                                                                    Text(
                                                                        '${order.phoneNumber} • ${order.totalAmount}'),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    Text(
                                                                        'Order ${order.id} • ${order.deliveryType}'),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 12),
                                                              SizedBox(
                                                                width: 170,
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    DropdownButtonFormField<
                                                                        String>(
                                                                      initialValue:
                                                                          displayValue,
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10,
                                                                            vertical:
                                                                                8),
                                                                        isDense:
                                                                            true,
                                                                      ),
                                                                      items: _assignees
                                                                          .map((assignee) => DropdownMenuItem<String>(
                                                                                value: assignee,
                                                                                child: Text(assignee),
                                                                              ))
                                                                          .toList(),
                                                                      onChanged:
                                                                          (assignee) async {
                                                                        await _assignOrder(
                                                                            context,
                                                                            order,
                                                                            assignee);
                                                                      },
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            6),
                                                                    InkWell(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      onTap: () =>
                                                                          _updateOrderStatusWithNotification(
                                                                        context,
                                                                        order,
                                                                        order.status ==
                                                                                'delivered'
                                                                            ? 'in_transit'
                                                                            : 'delivered',
                                                                        order.status ==
                                                                                'delivered'
                                                                            ? 'Order moved back to active delivery.'
                                                                            : 'Order marked as delivered.',
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                8,
                                                                            vertical:
                                                                                2),
                                                                        child:
                                                                            Text(
                                                                          order.status == 'delivered'
                                                                              ? 'Reopen'
                                                                              : 'Quick deliver',
                                                                          style:
                                                                              TextStyle(
                                                                            color: order.status == 'delivered'
                                                                                ? AppColors.warning
                                                                                : AppColors.success,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if ((showOverview || showNotifications) &&
                                        showNotifications) ...[
                                      const SizedBox(height: 16),
                                      notificationsAsync.when(
                                        data: (notifications) => Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                    'Dispatch Notifications',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                const SizedBox(height: 12),
                                                if (notifications.isEmpty)
                                                  const Text(
                                                      'No notifications yet')
                                                else
                                                  ...notifications
                                                      .take(5)
                                                      .map((notification) {
                                                    final title =
                                                        notification['title']
                                                                ?.toString() ??
                                                            'Update';
                                                    final message =
                                                        notification['message']
                                                                ?.toString() ??
                                                            '';
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .background,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                              color: AppColors
                                                                  .border),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(title,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(message,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                              ],
                                            ),
                                          ),
                                        ),
                                        loading: () => const Card(
                                            child: Center(
                                                child: CircularProgressIndicator
                                                    .adaptive())),
                                        error: (error, stack) => Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                                'Notifications unavailable: $error'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showOverview || showOrders)
                                    Expanded(
                                      flex: showNotifications ? 3 : 1,
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Recent Fuel Orders',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              const SizedBox(height: 12),
                                              Expanded(
                                                child: filtered.isEmpty
                                                    ? const Center(
                                                        child: Text(
                                                            'No orders found'))
                                                    : ListView.separated(
                                                        itemCount:
                                                            filtered.length,
                                                        separatorBuilder: (_,
                                                                __) =>
                                                            const Divider(
                                                                height: 1),
                                                        itemBuilder:
                                                            (context, i) {
                                                          final order =
                                                              filtered[i];
                                                          final rawAssignedTo =
                                                              order.assignedTo
                                                                  .trim();
                                                          final displayValue =
                                                              _assignees.contains(
                                                                      rawAssignedTo)
                                                                  ? rawAssignedTo
                                                                  : 'Unassigned';

                                                          return InkWell(
                                                            onTap: () =>
                                                                _showOrderDetails(
                                                                    context,
                                                                    order),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8.0),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Checkbox(
                                                                    value: _selectedOrderIds
                                                                        .contains(
                                                                            order.id),
                                                                    onChanged:
                                                                        (selected) {
                                                                      setState(
                                                                          () {
                                                                        if (selected ==
                                                                            true) {
                                                                          _selectedOrderIds
                                                                              .add(order.id);
                                                                        } else {
                                                                          _selectedOrderIds
                                                                              .remove(order.id);
                                                                        }
                                                                      });
                                                                    },
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Expanded(child: Text(order.requestName)),
                                                                            const SizedBox(width: 8),
                                                                            Container(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                              decoration: BoxDecoration(
                                                                                color: _statusColor(order.status).withValues(alpha: 0.12),
                                                                                borderRadius: BorderRadius.circular(999),
                                                                              ),
                                                                              child: Text(
                                                                                _statusLabel(order.status),
                                                                                style: TextStyle(
                                                                                  color: _statusColor(order.status),
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontSize: 11,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                4),
                                                                        Text(
                                                                            '${order.phoneNumber} • ${order.totalAmount}'),
                                                                        const SizedBox(
                                                                            height:
                                                                                2),
                                                                        Text(
                                                                            'Order ${order.id} • ${order.deliveryType}'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          12),
                                                                  SizedBox(
                                                                    width: 170,
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        DropdownButtonFormField<
                                                                            String>(
                                                                          initialValue:
                                                                              displayValue,
                                                                          decoration:
                                                                              const InputDecoration(
                                                                            contentPadding:
                                                                                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                                            isDense:
                                                                                true,
                                                                          ),
                                                                          items: _assignees
                                                                              .map((assignee) => DropdownMenuItem<String>(
                                                                                    value: assignee,
                                                                                    child: Text(assignee),
                                                                                  ))
                                                                              .toList(),
                                                                          onChanged:
                                                                              (assignee) async {
                                                                            await _assignOrder(
                                                                                context,
                                                                                order,
                                                                                assignee);
                                                                          },
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                6),
                                                                        InkWell(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          onTap: () =>
                                                                              _updateOrderStatusWithNotification(
                                                                            context,
                                                                            order,
                                                                            order.status == 'delivered'
                                                                                ? 'in_transit'
                                                                                : 'delivered',
                                                                            order.status == 'delivered'
                                                                                ? 'Order moved back to active delivery.'
                                                                                : 'Order marked as delivered.',
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                                            child:
                                                                                Text(
                                                                              order.status == 'delivered' ? 'Reopen' : 'Quick deliver',
                                                                              style: TextStyle(
                                                                                color: order.status == 'delivered' ? AppColors.warning : AppColors.success,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  if ((showOverview || showNotifications) &&
                                      showNotifications) ...[
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: notificationsAsync.when(
                                        data: (notifications) => Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                    'Dispatch Notifications',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                const SizedBox(height: 12),
                                                if (notifications.isEmpty)
                                                  const Text(
                                                      'No notifications yet')
                                                else
                                                  ...notifications
                                                      .take(5)
                                                      .map((notification) {
                                                    final title =
                                                        notification['title']
                                                                ?.toString() ??
                                                            'Update';
                                                    final message =
                                                        notification['message']
                                                                ?.toString() ??
                                                            '';
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .background,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                              color: AppColors
                                                                  .border),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(title,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(message,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyMedium),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                              ],
                                            ),
                                          ),
                                        ),
                                        loading: () => const Card(
                                            child: Center(
                                                child: CircularProgressIndicator
                                                    .adaptive())),
                                        error: (error, stack) => Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                                'Notifications unavailable: $error'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (error, stack) =>
                Center(child: Text('Costs unavailable: $error')),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (er, st) {
          return Center(child: Text('Failed to load orders: $er'));
        },
      ),
    );
  }
}
