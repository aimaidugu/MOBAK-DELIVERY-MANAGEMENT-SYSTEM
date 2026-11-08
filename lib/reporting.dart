import 'dart:convert';

import 'package:delivery/itemorder.dart';

Map<String, dynamic> summarizeOrders(List<ItemOrder> orders) {
  final statusCounts = <String, int>{};

  for (final order in orders) {
    final key = order.status.trim().isEmpty ? 'awaiting' : order.status;
    statusCounts[key] = (statusCounts[key] ?? 0) + 1;
  }

  final totalRevenue = orders.fold<double>(
    0,
    (sum, order) => sum + (double.tryParse(order.totalAmount) ?? 0),
  );

  return {
    'total_orders': orders.length,
    'total_revenue': totalRevenue,
    'pending_orders': statusCounts['pending'] ?? 0,
    'in_transit_orders': statusCounts['in_transit'] ?? 0,
    'delivered_orders': statusCounts['delivered'] ?? 0,
    'awaiting_orders': statusCounts['awaiting'] ?? 0,
    'status_count': statusCounts,
  };
}

String normalizeFuelCategory(String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  if (normalized == 'petrol' || normalized.contains('petrol')) {
    return 'petrol';
  }
  if (normalized == 'diesel' || normalized.contains('diesel')) {
    return 'diesel';
  }
  return '';
}

Map<String, dynamic> summarizeFuelMix(List<ItemOrder> orders) {
  var petrolOrders = 0;
  var dieselOrders = 0;
  var petrolLitres = 0.0;
  var dieselLitres = 0.0;

  for (final order in orders) {
    final fuelType = normalizeFuelCategory(order.deliveryType);

    if (fuelType == 'petrol') {
      petrolOrders += 1;
      petrolLitres += double.tryParse(order.quantityOil.trim()) ?? 0.0;
    } else if (fuelType == 'diesel') {
      dieselOrders += 1;
      dieselLitres += double.tryParse(order.quantityOil.trim()) ?? 0.0;
    }
  }

  return {
    'petrol_orders': petrolOrders,
    'diesel_orders': dieselOrders,
    'total_fuel_orders': petrolOrders + dieselOrders,
    'petrol_litres': petrolLitres,
    'diesel_litres': dieselLitres,
    'total_litres': petrolLitres + dieselLitres,
  };
}

List<ItemOrder> filterOrdersByFuelType(List<ItemOrder> orders, String fuelType) {
  final normalized = fuelType.trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'all') {
    return orders;
  }

  return orders.where((order) => normalizeFuelCategory(order.deliveryType) == normalized).toList();
}

Map<String, double> summarizeDailySales(List<ItemOrder> orders) {
  final dailyRevenue = <String, double>{};

  for (final order in orders) {
    final date = DateTime.tryParse(order.dateTime);
    final key = date == null ? 'unknown' : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final revenue = double.tryParse(order.totalAmount) ?? 0.0;
    dailyRevenue[key] = (dailyRevenue[key] ?? 0.0) + revenue;
  }

  return {
    ...dailyRevenue,
    'total_days': dailyRevenue.length.toDouble(),
  };
}

Map<String, dynamic> summarizePaymentStatus(List<ItemOrder> orders) {
  var paidOrders = 0;
  var unpaidOrders = 0;
  var totalPaidValue = 0.0;
  var totalUnpaidValue = 0.0;

  for (final order in orders) {
    final price = double.tryParse(order.totalAmount) ?? 0.0;
    final isPaid = order.status == 'delivered';

    if (isPaid) {
      paidOrders += 1;
      totalPaidValue += price;
    } else {
      unpaidOrders += 1;
      totalUnpaidValue += price;
    }
  }

  return {
    'paid_orders': paidOrders,
    'unpaid_orders': unpaidOrders,
    'total_paid_value': totalPaidValue,
    'total_unpaid_value': totalUnpaidValue,
  };
}

Map<String, dynamic> summarizeStockMovement(List<ItemOrder> orders) {
  var pendingLitres = 0.0;
  var inTransitLitres = 0.0;
  var deliveredLitres = 0.0;

  for (final order in orders) {
    final litres = double.tryParse(order.quantityOil.trim()) ?? 0.0;
    switch (order.status) {
      case 'pending':
      case 'awaiting':
        pendingLitres += litres;
        break;
      case 'in_transit':
        inTransitLitres += litres;
        break;
      case 'delivered':
        deliveredLitres += litres;
        break;
      default:
        break;
    }
  }

  return {
    'pending_litres': pendingLitres,
    'in_transit_litres': inTransitLitres,
    'delivered_litres': deliveredLitres,
    'total_allocated_litres': pendingLitres + inTransitLitres + deliveredLitres,
  };
}

Map<String, dynamic> summarizeDemandScore(List<ItemOrder> orders) {
  var urgentOrders = 0;
  var petrolPressure = 0.0;
  var dieselPressure = 0.0;

  for (final order in orders) {
    final litres = double.tryParse(order.quantityOil.trim()) ?? 0.0;
    final fuelType = normalizeFuelCategory(order.deliveryType);
    final isUrgent = order.status == 'awaiting' || order.status == 'pending';

    if (!isUrgent) {
      continue;
    }

    urgentOrders += 1;

    if (fuelType == 'petrol') {
      petrolPressure += litres;
    } else if (fuelType == 'diesel') {
      dieselPressure += litres;
    }
  }

  final dominantPressure = petrolPressure >= dieselPressure ? petrolPressure : dieselPressure;
  final demandScore = (urgentOrders * 30.0) + (dominantPressure * 1.125);
  final highestPressure = petrolPressure >= dieselPressure ? 'petrol' : 'diesel';

  return {
    'urgent_orders': urgentOrders,
    'demand_score': demandScore,
    'highest_pressure': highestPressure,
    'petrol_pressure': petrolPressure,
    'diesel_pressure': dieselPressure,
  };
}

Map<String, dynamic> summarizeRepeatBusiness(List<ItemOrder> orders) {
  final customerOrderCounts = <String, int>{};
  final customerRevenue = <String, double>{};

  for (final order in orders) {
    final key = order.phoneNumber.trim();
    if (key.isEmpty) continue;

    customerOrderCounts[key] = (customerOrderCounts[key] ?? 0) + 1;
    customerRevenue[key] = (customerRevenue[key] ?? 0.0) + (double.tryParse(order.totalAmount) ?? 0.0);
  }

  final repeatCustomers = customerOrderCounts.values.where((count) => count > 1).length;
  final newCustomers = customerOrderCounts.values.where((count) => count == 1).length;
  final repeatRevenue = customerOrderCounts.entries
      .where((entry) => entry.value > 1)
      .fold<double>(0.0, (sum, entry) => sum + (customerRevenue[entry.key] ?? 0.0));
  final totalCustomers = customerOrderCounts.length;

  final repeatRate = totalCustomers == 0 ? 0.0 : (repeatCustomers / totalCustomers) * 100.0;

  return {
    'repeat_customers': repeatCustomers,
    'new_customers': newCustomers,
    'repeat_rate': repeatRate,
    'repeat_revenue': repeatRevenue,
  };
}

Map<String, dynamic> summarizeAverageOrderValue(List<ItemOrder> orders) {
  if (orders.isEmpty) {
    return {
      'average_order_value': 0.0,
      'total_order_value': 0.0,
      'order_count': 0,
    };
  }

  final totalOrderValue = orders.fold<double>(
    0.0,
    (sum, order) => sum + (double.tryParse(order.totalAmount) ?? 0.0),
  );

  final averageValue = totalOrderValue / orders.length;

  return {
    'average_order_value': double.parse(averageValue.toStringAsFixed(2)),
    'total_order_value': totalOrderValue,
    'order_count': orders.length,
  };
}

Map<String, dynamic> summarizeSalesTrend(List<ItemOrder> orders) {
  final dailyRevenue = <String, double>{};

  for (final order in orders) {
    final date = DateTime.tryParse(order.dateTime);
    if (date == null) {
      continue;
    }

    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final revenue = double.tryParse(order.totalAmount) ?? 0.0;
    dailyRevenue[key] = (dailyRevenue[key] ?? 0.0) + revenue;
  }

  final sortedDays = dailyRevenue.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  var maxRevenue = 0.0;
  for (final entry in sortedDays) {
    if (entry.value > maxRevenue) {
      maxRevenue = entry.value;
    }
  }

  final dailyTrend = sortedDays.map((entry) {
    final revenue = double.parse(entry.value.toStringAsFixed(2));
    final percent = maxRevenue <= 0 ? 0.0 : (entry.value / maxRevenue) * 100.0;

    return {
      'date': entry.key,
      'revenue': revenue,
      'percent': double.parse(percent.toStringAsFixed(2)),
    };
  }).toList();

  final rankedByRevenue = List<Map<String, dynamic>>.from(dailyTrend)
    ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

  final totalRevenue = dailyTrend.fold<double>(0.0, (sum, entry) => sum + (entry['revenue'] as double));
  final averageDailyRevenue = dailyTrend.isEmpty ? 0.0 : totalRevenue / dailyTrend.length;
  final topDay = rankedByRevenue.isEmpty ? {'day': '', 'revenue': 0.0} : {
      'day': rankedByRevenue.first['date'],
      'revenue': rankedByRevenue.first['revenue'],
    };

  return {
    'daily_revenue': dailyRevenue,
    'daily_trend': dailyTrend,
    'top_day': topDay['day'] ?? '',
    'top_day_revenue': topDay['revenue'] ?? 0.0,
    'average_daily_revenue': double.parse(averageDailyRevenue.toStringAsFixed(2)),
    'active_days': dailyTrend.length,
  };
}

Map<String, dynamic> summarizeTopCustomers(List<ItemOrder> orders, {int limit = 5}) {
  final customerTotals = <String, Map<String, dynamic>>{};

  for (final order in orders) {
    final phone = order.phoneNumber.trim();
    if (phone.isEmpty) {
      continue;
    }

    final record = customerTotals.putIfAbsent(phone, () {
      return {
        'name': order.requestName,
        'orders': 0,
        'revenue': 0.0,
      };
    });

    record['name'] = (record['name'] as String).isEmpty ? order.requestName : record['name'];
    record['orders'] = (record['orders'] as int) + 1;
    record['revenue'] = (record['revenue'] as double) + (double.tryParse(order.totalAmount) ?? 0.0);
  }

  final ranked = customerTotals.entries.map((entry) {
    final orderCount = entry.value['orders'] as int;
    final revenue = entry.value['revenue'] as double;
    return {
      'phone': entry.key,
      'name': entry.value['name'] as String,
      'orders': orderCount,
      'revenue': double.parse(revenue.toStringAsFixed(2)),
      'average_order_value': double.parse((revenue / orderCount).toStringAsFixed(2)),
    };
  }).toList()
    ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

  final topCustomers = ranked.take(limit).toList();
  final topCustomer = topCustomers.isEmpty ? <String, dynamic>{} : topCustomers.first;

  return {
    'top_customers': topCustomers,
    'top_customer_name': topCustomer['name'] ?? '',
    'top_customer_phone': topCustomer['phone'] ?? '',
    'top_customer_orders': topCustomer['orders'] ?? 0,
    'top_customer_revenue': topCustomer['revenue'] ?? 0.0,
    'top_customer_average_order_value': topCustomer['average_order_value'] ?? 0.0,
  };
}

Map<String, dynamic> summarizeFleetUtilization(List<ItemOrder> orders, int deliveryCapacity) {
  final activeOrders = orders.where((order) => order.status == 'in_transit' || order.status == 'pending' || order.status == 'awaiting').length;
  final utilizationRate = deliveryCapacity <= 0 ? 0.0 : (activeOrders / deliveryCapacity) * 100.0;

  return {
    'active_orders': activeOrders,
    'utilization_rate': double.parse(utilizationRate.toStringAsFixed(2)),
    'delivery_capacity': deliveryCapacity,
    'idle_capacity': deliveryCapacity - activeOrders > 0 ? deliveryCapacity - activeOrders : 0,
  };
}

Map<String, dynamic> summarizeStockCoverage(List<ItemOrder> orders) {
  var pendingLitres = 0.0;
  var inTransitLitres = 0.0;
  var deliveredLitres = 0.0;

  for (final order in orders) {
    final litres = double.tryParse(order.quantityOil.trim()) ?? 0.0;
    switch (order.status) {
      case 'pending':
      case 'awaiting':
        pendingLitres += litres;
        break;
      case 'in_transit':
        inTransitLitres += litres;
        break;
      case 'delivered':
        deliveredLitres += litres;
        break;
      default:
        break;
    }
  }

  final demandLitres = pendingLitres + inTransitLitres;
  final readyLitres = deliveredLitres;
  final coverageRatio = demandLitres <= 0 ? 0.0 : (readyLitres / demandLitres) * 100.0;

  return {
    'pending_litres': pendingLitres,
    'in_transit_litres': inTransitLitres,
    'delivered_litres': deliveredLitres,
    'demand_litres': demandLitres,
    'ready_litres': readyLitres,
    'coverage_ratio': double.parse(coverageRatio.toStringAsFixed(2)),
    'fuel_balance': double.parse((readyLitres - demandLitres).toStringAsFixed(2)),
  };
}

Map<String, dynamic> summarizeFuelRevenueBreakdown(List<ItemOrder> orders) {
  var petrolRevenue = 0.0;
  var dieselRevenue = 0.0;

  for (final order in orders) {
    final fuelType = normalizeFuelCategory(order.deliveryType);
    final revenue = double.tryParse(order.totalAmount) ?? 0.0;

    if (fuelType == 'petrol') {
      petrolRevenue += revenue;
    } else if (fuelType == 'diesel') {
      dieselRevenue += revenue;
    }
  }

  final totalRevenue = petrolRevenue + dieselRevenue;
  final petrolShare = totalRevenue == 0.0 ? 0.0 : (petrolRevenue / totalRevenue) * 100.0;
  final dieselShare = totalRevenue == 0.0 ? 0.0 : (dieselRevenue / totalRevenue) * 100.0;

  return {
    'petrol_revenue': double.parse(petrolRevenue.toStringAsFixed(2)),
    'diesel_revenue': double.parse(dieselRevenue.toStringAsFixed(2)),
    'total_revenue': double.parse(totalRevenue.toStringAsFixed(2)),
    'petrol_share': double.parse(petrolShare.toStringAsFixed(2)),
    'diesel_share': double.parse(dieselShare.toStringAsFixed(2)),
  };
}

Map<String, dynamic> summarizeFuelProfitability(
  List<ItemOrder> orders, {
  double petrolCostPerLitre = 0.0,
  double dieselCostPerLitre = 0.0,
}) {
  var petrolRevenue = 0.0;
  var petrolLitres = 0.0;
  var dieselRevenue = 0.0;
  var dieselLitres = 0.0;

  for (final order in orders) {
    final fuelType = normalizeFuelCategory(order.deliveryType);
    final litres = double.tryParse(order.quantityOil.trim()) ?? 0.0;
    final revenue = double.tryParse(order.totalAmount) ?? 0.0;

    if (fuelType == 'petrol') {
      petrolRevenue += revenue;
      petrolLitres += litres;
    } else if (fuelType == 'diesel') {
      dieselRevenue += revenue;
      dieselLitres += litres;
    }
  }

  final petrolCost = petrolLitres * petrolCostPerLitre;
  final dieselCost = dieselLitres * dieselCostPerLitre;
  final petrolGrossProfit = petrolRevenue - petrolCost;
  final dieselGrossProfit = dieselRevenue - dieselCost;

  final petrolMarginPct = petrolRevenue == 0.0 ? 0.0 : (petrolGrossProfit / petrolRevenue) * 100.0;
  final dieselMarginPct = dieselRevenue == 0.0 ? 0.0 : (dieselGrossProfit / dieselRevenue) * 100.0;

  return {
    'petrol_revenue': double.parse(petrolRevenue.toStringAsFixed(2)),
    'diesel_revenue': double.parse(dieselRevenue.toStringAsFixed(2)),
    'petrol_litres': double.parse(petrolLitres.toStringAsFixed(2)),
    'diesel_litres': double.parse(dieselLitres.toStringAsFixed(2)),
    'petrol_cost': double.parse(petrolCost.toStringAsFixed(2)),
    'diesel_cost': double.parse(dieselCost.toStringAsFixed(2)),
    'petrol_gross_profit': double.parse(petrolGrossProfit.toStringAsFixed(2)),
    'diesel_gross_profit': double.parse(dieselGrossProfit.toStringAsFixed(2)),
    'petrol_margin_pct': double.parse(petrolMarginPct.toStringAsFixed(2)),
    'diesel_margin_pct': double.parse(dieselMarginPct.toStringAsFixed(2)),
  };
}

Map<String, dynamic> summarizeFuelStockBalance(
  List<ItemOrder> orders, {
  double petrolOpeningStock = 0.0,
  double dieselOpeningStock = 0.0,
}) {
  var petrolSoldLitres = 0.0;
  var petrolPendingLitres = 0.0;
  var dieselSoldLitres = 0.0;
  var dieselPendingLitres = 0.0;

  for (final order in orders) {
    final litres = double.tryParse(order.quantityOil.trim()) ?? 0.0;
    final fuelType = normalizeFuelCategory(order.deliveryType);

    if (fuelType == 'petrol') {
      if (order.status == 'delivered') {
        petrolSoldLitres += litres;
      } else if (order.status == 'pending' || order.status == 'awaiting' || order.status == 'in_transit') {
        petrolPendingLitres += litres;
      }
    } else if (fuelType == 'diesel') {
      if (order.status == 'delivered') {
        dieselSoldLitres += litres;
      } else if (order.status == 'pending' || order.status == 'awaiting' || order.status == 'in_transit') {
        dieselPendingLitres += litres;
      }
    }
  }

  final petrolRemainingLitres = petrolOpeningStock - petrolSoldLitres;
  final dieselRemainingLitres = dieselOpeningStock - dieselSoldLitres;

  final petrolCoveragePct = petrolOpeningStock <= 0 ? 0.0 : (petrolRemainingLitres / petrolOpeningStock) * 100.0;
  final dieselCoveragePct = dieselOpeningStock <= 0 ? 0.0 : (dieselRemainingLitres / dieselOpeningStock) * 100.0;

  return {
    'petrol_sold_litres': double.parse(petrolSoldLitres.toStringAsFixed(2)),
    'petrol_pending_litres': double.parse(petrolPendingLitres.toStringAsFixed(2)),
    'petrol_remaining_litres': double.parse(petrolRemainingLitres.toStringAsFixed(2)),
    'petrol_stock_coverage_pct': double.parse(petrolCoveragePct.toStringAsFixed(2)),
    'diesel_sold_litres': double.parse(dieselSoldLitres.toStringAsFixed(2)),
    'diesel_pending_litres': double.parse(dieselPendingLitres.toStringAsFixed(2)),
    'diesel_remaining_litres': double.parse(dieselRemainingLitres.toStringAsFixed(2)),
    'diesel_stock_coverage_pct': double.parse(dieselCoveragePct.toStringAsFixed(2)),
  };
}

Map<String, dynamic> summarizeFulfillmentRate(List<ItemOrder> orders) {
  final delivered = orders.where((order) => order.status == 'delivered').length;
  final pending = orders.where((order) => order.status != 'delivered').length;
  final total = orders.length;
  final fulfillmentRate = total == 0 ? 0.0 : (delivered / total) * 100.0;

  return {
    'delivered_orders': delivered,
    'pending_orders': pending,
    'total_orders': total,
    'fulfillment_rate': double.parse(fulfillmentRate.toStringAsFixed(2)),
  };
}

Map<String, dynamic> summarizeRestockAlerts({
  required double petrolRemainingLitres,
  required double dieselRemainingLitres,
  double petrolThresholdLitres = 50.0,
  double dieselThresholdLitres = 50.0,
}) {
  final petrolNeedsRestock = petrolRemainingLitres < petrolThresholdLitres;
  final dieselNeedsRestock = dieselRemainingLitres < dieselThresholdLitres;

  final restockItems = <String>[];
  if (petrolNeedsRestock) {
    restockItems.add('petrol');
  }
  if (dieselNeedsRestock) {
    restockItems.add('diesel');
  }

  return {
    'petrol_needs_restock': petrolNeedsRestock,
    'diesel_needs_restock': dieselNeedsRestock,
    'restock_items': restockItems,
    'restock_count': restockItems.length,
    'petrol_remaining_litres': double.parse(petrolRemainingLitres.toStringAsFixed(2)),
    'diesel_remaining_litres': double.parse(dieselRemainingLitres.toStringAsFixed(2)),
    'petrol_threshold_litres': double.parse(petrolThresholdLitres.toStringAsFixed(2)),
    'diesel_threshold_litres': double.parse(dieselThresholdLitres.toStringAsFixed(2)),
  };
}

Map<String, dynamic> summarizeRestockRecommendation({
  required double petrolRemainingLitres,
  required double dieselRemainingLitres,
  required double petrolDailyDemandLitres,
  required double dieselDailyDemandLitres,
  double petrolTargetLitres = 120.0,
  double dieselTargetLitres = 110.0,
}) {
  final petrolShortfall = (petrolTargetLitres - petrolRemainingLitres).clamp(0.0, double.infinity);
  final dieselShortfall = (dieselTargetLitres - dieselRemainingLitres).clamp(0.0, double.infinity);
  final petrolDemandBuffer = petrolDailyDemandLitres * 1.5;
  final dieselDemandBuffer = dieselDailyDemandLitres * 1.5;

  final petrolRecommendedLitres = petrolShortfall + petrolDemandBuffer;
  final dieselRecommendedLitres = dieselShortfall + dieselDemandBuffer;

  final restockItems = <String>[];
  if (petrolRecommendedLitres > 0) {
    restockItems.add('petrol');
  }
  if (dieselRecommendedLitres > 0) {
    restockItems.add('diesel');
  }

  return {
    'petrol_needs_restock': petrolRecommendedLitres > 0,
    'diesel_needs_restock': dieselRecommendedLitres > 0,
    'restock_items': restockItems,
    'restock_count': restockItems.length,
    'petrol_recommended_litres': double.parse(petrolRecommendedLitres.toStringAsFixed(2)),
    'diesel_recommended_litres': double.parse(dieselRecommendedLitres.toStringAsFixed(2)),
    'petrol_target_litres': double.parse(petrolTargetLitres.toStringAsFixed(2)),
    'diesel_target_litres': double.parse(dieselTargetLitres.toStringAsFixed(2)),
  };
}

Map<String, dynamic> summarizeStockReconciliation({
  required double petrolOpeningStock,
  required double petrolSoldLitres,
  required double petrolRestockedLitres,
  required double dieselOpeningStock,
  required double dieselSoldLitres,
  required double dieselRestockedLitres,
}) {
  final petrolClosingStock = petrolOpeningStock - petrolSoldLitres + petrolRestockedLitres;
  final dieselClosingStock = dieselOpeningStock - dieselSoldLitres + dieselRestockedLitres;

  final petrolNetVariance = petrolClosingStock - petrolOpeningStock;
  final dieselNetVariance = dieselClosingStock - dieselOpeningStock;

  final petrolNeedsReview = petrolNetVariance.abs() > 10.0;
  final dieselNeedsReview = dieselNetVariance.abs() > 10.0;
  final status = petrolNeedsReview || dieselNeedsReview ? 'needs_review' : 'balanced';

  return {
    'petrol_closing_stock': double.parse(petrolClosingStock.toStringAsFixed(2)),
    'diesel_closing_stock': double.parse(dieselClosingStock.toStringAsFixed(2)),
    'petrol_net_variance': double.parse(petrolNetVariance.toStringAsFixed(2)),
    'diesel_net_variance': double.parse(dieselNetVariance.toStringAsFixed(2)),
    'reconciliation_status': status,
  };
}

Map<String, dynamic> summarizeAverageLitresPerOrder(List<ItemOrder> orders) {
  if (orders.isEmpty) {
    return {
      'average_litres_per_order': 0.0,
      'total_litres': 0.0,
      'order_count': 0,
    };
  }

  final totalLitres = orders.fold<double>(
    0.0,
    (sum, order) => sum + (double.tryParse(order.quantityOil.trim()) ?? 0.0),
  );

  final average = totalLitres / orders.length;

  return {
    'average_litres_per_order': double.parse(average.toStringAsFixed(2)),
    'total_litres': double.parse(totalLitres.toStringAsFixed(2)),
    'order_count': orders.length,
  };
}

String _escapeCsvField(Object? value) {
  final text = value?.toString() ?? '';
  final escaped = text.replaceAll('"', '""');
  return '"$escaped"';
}

String buildOrderCsvReport(List<ItemOrder> orders) {
  final summary = summarizeOrders(orders);
  final timestamp = DateTime.now().toUtc().toIso8601String();

  final buffer = StringBuffer();
  buffer.writeln('report_generated_at,$timestamp');
  buffer.writeln('total_orders,${summary['total_orders']}');
  buffer.writeln('total_revenue,${summary['total_revenue']}');
  buffer.writeln('pending_orders,${summary['pending_orders']}');
  buffer.writeln('in_transit_orders,${summary['in_transit_orders']}');
  buffer.writeln('delivered_orders,${summary['delivered_orders']}');
  buffer.writeln('awaiting_orders,${summary['awaiting_orders']}');
  buffer.writeln('status_count,${jsonEncode(summary['status_count'])}');
  buffer.writeln(
    'order_id,request_name,status,total_amount,assigned_to,delivery_type,phone_number,delivery_address,destination_address,date_time,quantity_oil',
  );

  for (final order in orders) {
    buffer.writeln([
      order.id,
      order.requestName,
      order.status,
      order.totalAmount,
      order.assignedTo.isEmpty ? 'Unassigned' : order.assignedTo,
      order.deliveryType,
      order.phoneNumber,
      order.deliveryAddress,
      order.destinationAddress,
      order.dateTime,
      order.quantityOil,
    ].map(_escapeCsvField).join(','));
  }

  return buffer.toString();
}
