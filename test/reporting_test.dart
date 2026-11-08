import 'package:delivery/itemorder.dart';
import 'package:delivery/providers.dart';
import 'package:delivery/reporting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('reporting', () {
    test('customer order total adds fuel cost and distance-based delivery fee',
        () {
      final deliveryFee = calculateDeliveryFee(12, 75);

      expect(deliveryFee, 900);
      expect(
        calculateOrderTotal(fuelCost: 5000, deliveryFee: deliveryFee),
        5900,
      );
    });

    test('pending order filters include legacy and current pending statuses',
        () {
      expect(isPendingOrderStatus('awaiting_payment'), isTrue);
      expect(isPendingOrderStatus('awaiting'), isTrue);
      expect(isPendingOrderStatus('pending'), isTrue);
      expect(isPendingOrderStatus('delivered'), isFalse);
      expect(matchesOrderStatusFilter('awaiting_payment', 'pending'), isTrue);
      expect(matchesOrderStatusFilter('delivered', 'delivered'), isTrue);
      expect(matchesOrderStatusFilter('dispatched', 'delivered'), isFalse);
    });

    test('readCostMapValue accepts legacy and alternate price field names', () {
      expect(readCostMapValue({'Price': '135.50'}), 135.5);
      expect(readCostMapValue({'cost': '120.00'}), 120.0);
      expect(readCostMapValue({'Value': '99.99'}), 99.99);
      expect(readCostMapValue({}), 0.0);
    });

    test(
        'buildDeliveryStatePriceMap parses state pricing rows without crashing',
        () {
      final statePrices = buildDeliveryStatePriceMap([
        {'state': 'Lagos', 'price': '1500'},
        {'state': 'Abia', 'cost': 2200.0},
        {'state': 'Kaduna', 'amount': '1800'},
      ]);

      expect(statePrices['Lagos'], 1500.0);
      expect(statePrices['Abia'], 2200.0);
      expect(statePrices['Kaduna'], 1800.0);
      expect(buildDeliveryStatePriceMap([]), isEmpty);
    });

    test(
        'buildDeliveryStatePerKmMap handles empty and missing per-km entries safely',
        () {
      final perKm = buildDeliveryStatePerKmMap([
        {'state': 'Lagos', 'per_km': '75.5'},
        {'state': 'Kano', 'perKm': 90},
        {'state': 'Abia', 'perKmRate': '0'},
      ]);

      expect(perKm['Lagos'], 75.5);
      expect(perKm['Kano'], 90.0);
      expect(perKm['Abia'], 0.0);
      expect(buildDeliveryStatePerKmMap([]), isEmpty);
    });

    test('ItemOrder.fromMap accepts legacy and alternate field names', () {
      final order = ItemOrder.fromMap({
        'orderId': 'ORD-999',
        'customerName': 'Grace Okafor',
        'fuelType': 'diesel',
        'litres': '18.5',
        'phone': '08055555555',
        'deliveryAddress': 'Plot 12',
        'destinationAddress': 'Main Road',
        'recipientPhone': '08044444444',
        'amount': '4200',
        'status': 'in_transit',
        'assignedTo': 'Warehouse',
      });

      expect(order.id, 'ORD-999');
      expect(order.requestName, 'Grace Okafor');
      expect(order.deliveryType, 'diesel');
      expect(order.quantityOil, '18.5');
      expect(order.phoneNumber, '08055555555');
      expect(order.totalAmount, '4200');
      expect(order.status, 'in_transit');
      expect(order.assignedTo, 'Warehouse');
    });

    test('buildOrderCsvReport includes the expected summary and order rows',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-100',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08012345678',
          deliveryAddress: '12 Main Street',
          destinationAddress: '15 Green Road',
          deliveryType: 'express',
          quantityOil: '40',
          recepientNumber: '08000000000',
          requestName: 'Ada Smith',
          status: 'pending',
          totalAmount: '2500',
          assignedTo: 'Dispatch',
        ),
        ItemOrder(
          id: 'ORD-101',
          dateTime: '2026-09-06T12:00:00Z',
          phoneNumber: '08087654321',
          deliveryAddress: '6 Market Lane',
          destinationAddress: '9 Palm Avenue',
          deliveryType: 'standard',
          quantityOil: '20',
          recepientNumber: '08011111111',
          requestName: 'John Doe',
          status: 'delivered',
          totalAmount: '3200',
          assignedTo: 'Fleet Ops',
        ),
      ];

      final csv = buildOrderCsvReport(orders);

      expect(csv, contains('report_generated_at'));
      expect(csv, contains('ORD-100'));
      expect(csv, contains('ORD-101'));
      expect(csv, contains('pending'));
      expect(csv, contains('delivered'));
      expect(csv, contains('status_count'));
    });

    test('summarizeOrders includes totals and status counts', () {
      final orders = [
        ItemOrder(
          id: 'ORD-200',
          dateTime: '2026-09-06T08:00:00Z',
          phoneNumber: '08022222222',
          deliveryAddress: '1 Old Road',
          destinationAddress: '2 New Road',
          deliveryType: 'express',
          quantityOil: '30',
          recepientNumber: '08033333333',
          requestName: 'Jane Doe',
          status: 'pending',
          totalAmount: '5000',
        ),
        ItemOrder(
          id: 'ORD-201',
          dateTime: '2026-09-06T09:30:00Z',
          phoneNumber: '08044444444',
          deliveryAddress: '3 West Rd',
          destinationAddress: '4 East Rd',
          deliveryType: 'standard',
          quantityOil: '10',
          recepientNumber: '08055555555',
          requestName: 'Mia Kay',
          status: 'pending',
          totalAmount: '2000',
        ),
        ItemOrder(
          id: 'ORD-202',
          dateTime: '2026-09-06T11:00:00Z',
          phoneNumber: '08066666666',
          deliveryAddress: '5 Ridge Hill',
          destinationAddress: '6 River Lane',
          deliveryType: 'express',
          quantityOil: '15',
          recepientNumber: '08077777777',
          requestName: 'Ben Park',
          status: 'delivered',
          totalAmount: '1600',
        ),
      ];

      final summary = summarizeOrders(orders);

      expect(summary['total_orders'], 3);
      expect(summary['pending_orders'], 2);
      expect(summary['delivered_orders'], 1);
      expect(summary['total_revenue'], 8600.0);
    });

    test('summarizeTopCustomers ranks the highest-value buyers by total spend',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-210',
          dateTime: '2026-09-06T08:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: '1 Old Road',
          destinationAddress: '2 New Road',
          deliveryType: 'petrol',
          quantityOil: '30',
          recepientNumber: '08033333333',
          requestName: 'Alice',
          status: 'pending',
          totalAmount: '5000',
        ),
        ItemOrder(
          id: 'ORD-211',
          dateTime: '2026-09-06T09:30:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: '3 West Rd',
          destinationAddress: '4 East Rd',
          deliveryType: 'petrol',
          quantityOil: '10',
          recepientNumber: '08055555555',
          requestName: 'Alice',
          status: 'delivered',
          totalAmount: '2000',
        ),
        ItemOrder(
          id: 'ORD-212',
          dateTime: '2026-09-06T11:00:00Z',
          phoneNumber: '08022222222',
          deliveryAddress: '5 Ridge Hill',
          destinationAddress: '6 River Lane',
          deliveryType: 'diesel',
          quantityOil: '15',
          recepientNumber: '08077777777',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '4200',
        ),
      ];

      final summary = summarizeTopCustomers(orders, limit: 2);

      expect(summary['top_customer_name'], 'Alice');
      expect(summary['top_customer_revenue'], 7000.0);
      expect(summary['top_customer_orders'], 2);
      expect((summary['top_customers'] as List).first['name'], 'Alice');
    });

    test(
        'summarizeSalesTrend identifies the strongest day and average revenue per day',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-220',
          dateTime: '2026-09-06T08:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: '1 Old Road',
          destinationAddress: '2 New Road',
          deliveryType: 'petrol',
          quantityOil: '30',
          recepientNumber: '08033333333',
          requestName: 'Alice',
          status: 'pending',
          totalAmount: '5000',
        ),
        ItemOrder(
          id: 'ORD-221',
          dateTime: '2026-09-06T09:30:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: '3 West Rd',
          destinationAddress: '4 East Rd',
          deliveryType: 'diesel',
          quantityOil: '10',
          recepientNumber: '08055555555',
          requestName: 'Alice',
          status: 'delivered',
          totalAmount: '2500',
        ),
        ItemOrder(
          id: 'ORD-222',
          dateTime: '2026-09-07T11:00:00Z',
          phoneNumber: '08022222222',
          deliveryAddress: '5 Ridge Hill',
          destinationAddress: '6 River Lane',
          deliveryType: 'petrol',
          quantityOil: '15',
          recepientNumber: '08077777777',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '1500',
        ),
      ];

      final summary = summarizeSalesTrend(orders);

      expect(summary['top_day'], '2026-09-06');
      expect(summary['top_day_revenue'], 7500.0);
      expect(summary['average_daily_revenue'], 4500.0);
      expect(summary['daily_trend'], isNotEmpty);
      expect((summary['daily_trend'] as List).first['date'], '2026-09-06');
    });

    test(
        'summarizeFuelProfitability estimates gross margin by fuel type from cost base',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-230',
          dateTime: '2026-09-06T08:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: '1 Old Road',
          destinationAddress: '2 New Road',
          deliveryType: 'petrol',
          quantityOil: '30',
          recepientNumber: '08033333333',
          requestName: 'Alice',
          status: 'pending',
          totalAmount: '6000',
        ),
        ItemOrder(
          id: 'ORD-231',
          dateTime: '2026-09-06T09:30:00Z',
          phoneNumber: '08022222222',
          deliveryAddress: '3 West Rd',
          destinationAddress: '4 East Rd',
          deliveryType: 'diesel',
          quantityOil: '20',
          recepientNumber: '08055555555',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '3000',
        ),
      ];

      final summary = summarizeFuelProfitability(
        orders,
        petrolCostPerLitre: 160.0,
        dieselCostPerLitre: 140.0,
      );

      expect(summary['petrol_revenue'], 6000.0);
      expect(summary['diesel_revenue'], 3000.0);
      expect(summary['petrol_gross_profit'], 1200.0);
      expect(summary['diesel_gross_profit'], 200.0);
      expect(summary['petrol_margin_pct'], 20.0);
      expect(summary['diesel_margin_pct'], 6.67);
    });

    test(
        'summarizeFuelStockBalance tracks remaining stock by fuel type for a basic litre manager',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-240',
          dateTime: '2026-09-06T08:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: '1 Old Road',
          destinationAddress: '2 New Road',
          deliveryType: 'petrol',
          quantityOil: '25',
          recepientNumber: '08033333333',
          requestName: 'Alice',
          status: 'delivered',
          totalAmount: '5000',
        ),
        ItemOrder(
          id: 'ORD-241',
          dateTime: '2026-09-06T09:30:00Z',
          phoneNumber: '08022222222',
          deliveryAddress: '3 West Rd',
          destinationAddress: '4 East Rd',
          deliveryType: 'diesel',
          quantityOil: '20',
          recepientNumber: '08055555555',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '3000',
        ),
        ItemOrder(
          id: 'ORD-242',
          dateTime: '2026-09-06T12:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: '7 Main Road',
          destinationAddress: '8 New Road',
          deliveryType: 'petrol',
          quantityOil: '10',
          recepientNumber: '08066666666',
          requestName: 'Alice',
          status: 'pending',
          totalAmount: '2000',
        ),
      ];

      final summary = summarizeFuelStockBalance(
        orders,
        petrolOpeningStock: 200.0,
        dieselOpeningStock: 180.0,
      );

      expect(summary['petrol_sold_litres'], 25.0);
      expect(summary['diesel_sold_litres'], 20.0);
      expect(summary['petrol_pending_litres'], 10.0);
      expect(summary['diesel_pending_litres'], 0.0);
      expect(summary['petrol_remaining_litres'], 175.0);
      expect(summary['diesel_remaining_litres'], 160.0);
      expect(summary['petrol_stock_coverage_pct'], 87.5);
      expect(summary['diesel_stock_coverage_pct'], 88.89);
    });

    test('summarizeRestockAlerts flags fuel types below the safe threshold',
        () {
      final stockStatus = summarizeRestockAlerts(
        petrolRemainingLitres: 35.0,
        dieselRemainingLitres: 120.0,
        petrolThresholdLitres: 50.0,
        dieselThresholdLitres: 100.0,
      );

      expect(stockStatus['petrol_needs_restock'], true);
      expect(stockStatus['diesel_needs_restock'], false);
      expect(stockStatus['restock_items'], contains('petrol'));
      expect(stockStatus['restock_count'], 1);
    });

    test(
        'summarizeRestockRecommendation recommends litres to refill to target stock and cover demand',
        () {
      final recommendation = summarizeRestockRecommendation(
        petrolRemainingLitres: 42.0,
        dieselRemainingLitres: 87.0,
        petrolDailyDemandLitres: 28.0,
        dieselDailyDemandLitres: 24.0,
        petrolTargetLitres: 120.0,
        dieselTargetLitres: 110.0,
      );

      expect(recommendation['petrol_recommended_litres'], 120.0);
      expect(recommendation['diesel_recommended_litres'], 59.0);
      expect(recommendation['petrol_needs_restock'], true);
      expect(recommendation['diesel_needs_restock'], true);
      expect(
          recommendation['restock_items'], containsAll(['petrol', 'diesel']));
    });

    test(
        'summarizeStockReconciliation balances opening, sold, and closing stock for each fuel type',
        () {
      final summary = summarizeStockReconciliation(
        petrolOpeningStock: 200.0,
        petrolSoldLitres: 55.0,
        petrolRestockedLitres: 20.0,
        dieselOpeningStock: 180.0,
        dieselSoldLitres: 60.0,
        dieselRestockedLitres: 10.0,
      );

      expect(summary['petrol_closing_stock'], 165.0);
      expect(summary['diesel_closing_stock'], 130.0);
      expect(summary['petrol_net_variance'], -35.0);
      expect(summary['diesel_net_variance'], -50.0);
      expect(summary['reconciliation_status'], 'needs_review');
    });

    test(
        'cost normalization tolerates missing documents and legacy field names',
        () {
      expect(readCostMapValue({'cost': 125.5}), 125.5);
      expect(readCostMapValue({'Cost': '250.75'}), 250.75);
      expect(readCostMapValue({}), 0.0);
      expect(readCostMapValue(null), 0.0);
    });

    test(
        'fuel type normalization accepts the supported petrol and diesel values',
        () {
      expect(normalizeFuelType(' PETROL '), 'petrol');
      expect(normalizeFuelType('Diesel'), 'diesel');
      expect(normalizeFuelType('unknown'), 'petrol');
    });

    test('summarizeFuelMix reports petrol and diesel order counts', () {
      final orders = [
        ItemOrder(
          id: 'ORD-400',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '20',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'awaiting',
          totalAmount: '1500',
        ),
        ItemOrder(
          id: 'ORD-401',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'C',
          destinationAddress: 'D',
          deliveryType: 'diesel',
          quantityOil: '10',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'pending',
          totalAmount: '1700',
        ),
        ItemOrder(
          id: 'ORD-402',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '30',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'delivered',
          totalAmount: '2250',
        ),
      ];

      final summary = summarizeFuelMix(orders);

      expect(summary['petrol_orders'], 2);
      expect(summary['diesel_orders'], 1);
      expect(summary['total_fuel_orders'], 3);
    });

    test('summarizeFuelMix tracks total litres sold by fuel type', () {
      final orders = [
        ItemOrder(
          id: 'ORD-500',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '25',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'pending',
          totalAmount: '1700',
        ),
        ItemOrder(
          id: 'ORD-501',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'C',
          destinationAddress: 'D',
          deliveryType: 'diesel',
          quantityOil: '35',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '2500',
        ),
        ItemOrder(
          id: 'ORD-502',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '15',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'in_transit',
          totalAmount: '1200',
        ),
      ];

      final summary = summarizeFuelMix(orders);

      expect(summary['petrol_litres'], 40.0);
      expect(summary['diesel_litres'], 35.0);
      expect(summary['total_litres'], 75.0);
    });

    test(
        'filterOrdersByFuelType isolates diesel or petrol orders by fuel category',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-600',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '25',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'pending',
          totalAmount: '1700',
        ),
        ItemOrder(
          id: 'ORD-601',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'C',
          destinationAddress: 'D',
          deliveryType: 'diesel',
          quantityOil: '35',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '2500',
        ),
      ];

      expect(filterOrdersByFuelType(orders, 'petrol').length, 1);
      expect(filterOrdersByFuelType(orders, 'diesel').single.deliveryType,
          'diesel');
      expect(filterOrdersByFuelType(orders, 'all').length, 2);
    });

    test('summarizeDailySales groups revenue by day for retailer reporting',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-700',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '25',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'pending',
          totalAmount: '1700',
        ),
        ItemOrder(
          id: 'ORD-701',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'C',
          destinationAddress: 'D',
          deliveryType: 'diesel',
          quantityOil: '35',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '2500',
        ),
        ItemOrder(
          id: 'ORD-702',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '15',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'delivered',
          totalAmount: '1200',
        ),
      ];

      final summary = summarizeDailySales(orders);

      expect(summary['2026-09-06'], 4200.0);
      expect(summary['2026-09-07'], 1200.0);
      expect(summary['total_days'], 2);
    });

    test(
        'summarizePaymentStatus groups orders by payment state for retailer cashflow',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-800',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '25',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'pending',
          totalAmount: '1700',
        ),
        ItemOrder(
          id: 'ORD-801',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'C',
          destinationAddress: 'D',
          deliveryType: 'diesel',
          quantityOil: '35',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '2500',
        ),
        ItemOrder(
          id: 'ORD-802',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '15',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'pending',
          totalAmount: '1200',
        ),
      ];

      final summary = summarizePaymentStatus(orders);

      expect(summary['paid_orders'], 1);
      expect(summary['unpaid_orders'], 2);
      expect(summary['total_paid_value'], 2500.0);
      expect(summary['total_unpaid_value'], 2900.0);
    });

    test(
        'summarizeStockMovement tracks litres allocated to active dispatch and ready stock',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-900',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '25',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'pending',
          totalAmount: '1700',
        ),
        ItemOrder(
          id: 'ORD-901',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'C',
          destinationAddress: 'D',
          deliveryType: 'diesel',
          quantityOil: '35',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'in_transit',
          totalAmount: '2500',
        ),
        ItemOrder(
          id: 'ORD-902',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '15',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'delivered',
          totalAmount: '1200',
        ),
      ];

      final summary = summarizeStockMovement(orders);

      expect(summary['pending_litres'], 25.0);
      expect(summary['in_transit_litres'], 35.0);
      expect(summary['delivered_litres'], 15.0);
      expect(summary['total_allocated_litres'], 75.0);
    });

    test(
        'summarizeDemandScore ranks order pressure by urgent status and fuel volume',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-1000',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '40',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'awaiting',
          totalAmount: '2600',
        ),
        ItemOrder(
          id: 'ORD-1001',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'C',
          destinationAddress: 'D',
          deliveryType: 'diesel',
          quantityOil: '25',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'pending',
          totalAmount: '1800',
        ),
        ItemOrder(
          id: 'ORD-1002',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '10',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'delivered',
          totalAmount: '900',
        ),
      ];

      final summary = summarizeDemandScore(orders);

      expect(summary['urgent_orders'], 2);
      expect(summary['demand_score'], 105.0);
      expect(summary['highest_pressure'], 'petrol');
    });

    test(
        'summarizeRepeatBusiness tracks customer retention by repeated fuel buyers',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-1100',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '40',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'awaiting',
          totalAmount: '2600',
        ),
        ItemOrder(
          id: 'ORD-1101',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '30',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'delivered',
          totalAmount: '2000',
        ),
        ItemOrder(
          id: 'ORD-1102',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'diesel',
          quantityOil: '15',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'pending',
          totalAmount: '900',
        ),
      ];

      final summary = summarizeRepeatBusiness(orders);

      expect(summary['repeat_customers'], 1);
      expect(summary['new_customers'], 1);
      expect(summary['repeat_rate'], 50.0);
      expect(summary['repeat_revenue'], 4600.0);
    });

    test(
        'summarizeAverageOrderValue reports the average basket size across retailer orders',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-1200',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '40',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'awaiting',
          totalAmount: '2600',
        ),
        ItemOrder(
          id: 'ORD-1201',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'diesel',
          quantityOil: '30',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '2000',
        ),
        ItemOrder(
          id: 'ORD-1202',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '15',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'pending',
          totalAmount: '900',
        ),
      ];

      final summary = summarizeAverageOrderValue(orders);

      expect(summary['average_order_value'], 1833.33);
      expect(summary['total_order_value'], 5500.0);
      expect(summary['order_count'], 3);
    });

    test(
        'summarizeFleetUtilization measures active delivery efficiency for dispatch capacity',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-1300',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '40',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'in_transit',
          totalAmount: '2600',
        ),
        ItemOrder(
          id: 'ORD-1301',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'diesel',
          quantityOil: '30',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '2000',
        ),
        ItemOrder(
          id: 'ORD-1302',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '15',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'pending',
          totalAmount: '900',
        ),
      ];

      final summary = summarizeFleetUtilization(orders, 4);

      expect(summary['active_orders'], 2);
      expect(summary['utilization_rate'], 50.0);
      expect(summary['delivery_capacity'], 4);
      expect(summary['idle_capacity'], 2);
    });

    test(
        'summarizeStockCoverage reports whether delivered stock covers active fuel demand',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-1400',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '30',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'pending',
          totalAmount: '2000',
        ),
        ItemOrder(
          id: 'ORD-1401',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'diesel',
          quantityOil: '20',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'in_transit',
          totalAmount: '1800',
        ),
        ItemOrder(
          id: 'ORD-1402',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'diesel',
          quantityOil: '50',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'delivered',
          totalAmount: '3200',
        ),
      ];

      final summary = summarizeStockCoverage(orders);

      expect(summary['pending_litres'], 30.0);
      expect(summary['in_transit_litres'], 20.0);
      expect(summary['delivered_litres'], 50.0);
      expect(summary['demand_litres'], 50.0);
      expect(summary['ready_litres'], 50.0);
      expect(summary['coverage_ratio'], 100.0);
      expect(summary['fuel_balance'], 0.0);
    });

    test(
        'summarizeFuelRevenueBreakdown reports revenue contribution by fuel type',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-1500',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '40',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'delivered',
          totalAmount: '2600',
        ),
        ItemOrder(
          id: 'ORD-1501',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'diesel',
          quantityOil: '30',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '2000',
        ),
        ItemOrder(
          id: 'ORD-1502',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '15',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'pending',
          totalAmount: '900',
        ),
      ];

      final summary = summarizeFuelRevenueBreakdown(orders);

      expect(summary['petrol_revenue'], 3500.0);
      expect(summary['diesel_revenue'], 2000.0);
      expect(summary['total_revenue'], 5500.0);
      expect(summary['petrol_share'], 63.64);
      expect(summary['diesel_share'], 36.36);
    });

    test(
        'summarizeFulfillmentRate measures percentage of orders completed on time',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-1600',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '40',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'delivered',
          totalAmount: '2600',
        ),
        ItemOrder(
          id: 'ORD-1601',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'diesel',
          quantityOil: '30',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '2000',
        ),
        ItemOrder(
          id: 'ORD-1602',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '15',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'pending',
          totalAmount: '900',
        ),
      ];

      final summary = summarizeFulfillmentRate(orders);

      expect(summary['delivered_orders'], 2);
      expect(summary['pending_orders'], 1);
      expect(summary['total_orders'], 3);
      expect(summary['fulfillment_rate'], 66.67);
    });

    test(
        'summarizeAverageLitresPerOrder tracks typical fuel volume per customer order',
        () {
      final orders = [
        ItemOrder(
          id: 'ORD-1700',
          dateTime: '2026-09-06T10:00:00Z',
          phoneNumber: '08011111111',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'petrol',
          quantityOil: '40',
          recepientNumber: '08022222222',
          requestName: 'Alice',
          status: 'delivered',
          totalAmount: '2600',
        ),
        ItemOrder(
          id: 'ORD-1701',
          dateTime: '2026-09-06T13:00:00Z',
          phoneNumber: '08033333333',
          deliveryAddress: 'A',
          destinationAddress: 'B',
          deliveryType: 'diesel',
          quantityOil: '30',
          recepientNumber: '08044444444',
          requestName: 'Bob',
          status: 'delivered',
          totalAmount: '2000',
        ),
        ItemOrder(
          id: 'ORD-1702',
          dateTime: '2026-09-07T08:00:00Z',
          phoneNumber: '08055555555',
          deliveryAddress: 'E',
          destinationAddress: 'F',
          deliveryType: 'petrol',
          quantityOil: '15',
          recepientNumber: '08066666666',
          requestName: 'Cleo',
          status: 'pending',
          totalAmount: '900',
        ),
      ];

      final summary = summarizeAverageLitresPerOrder(orders);

      expect(summary['average_litres_per_order'], 28.33);
      expect(summary['total_litres'], 85.0);
      expect(summary['order_count'], 3);
    });
  });
}
