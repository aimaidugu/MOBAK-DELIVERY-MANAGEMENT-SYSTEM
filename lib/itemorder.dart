class ItemOrder {
  String id;
  String requestName;
  String deliveryAddress;
  String destinationAddress;
  String totalAmount;
  String dateTime;
  String status;
  String recepientNumber;
  String deliveryType;
  String phoneNumber;
  String quantityOil;
  String assignedTo;
  String state;
  String distanceKm;
  String deliveryFee;
  String deliveryPerKm;

  ItemOrder(
      {required this.id,
      required this.dateTime,
      required this.phoneNumber,
      required this.deliveryAddress,
      required this.destinationAddress,
      required this.deliveryType,
      required this.quantityOil,
      required this.recepientNumber,
      required this.requestName,
      required this.status,
      required this.totalAmount,
      this.assignedTo = '',
      this.state = '',
      this.distanceKm = '',
      this.deliveryFee = '',
      this.deliveryPerKm = ''});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'dateTime': dateTime,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'deliveryType': deliveryType,
      'recepientNumber': recepientNumber,
      'destinationAddress': destinationAddress,
      'quantityOil': quantityOil,
      'requestName': requestName,
      'status': status,
      'totalAmount': totalAmount,
      'assignedTo': assignedTo,
      'state': state,
      'distanceKm': distanceKm,
      'deliveryFee': deliveryFee,
      'deliveryPerKm': deliveryPerKm,
    };
  }

  factory ItemOrder.fromMap(Map<String, dynamic> map) {
    final candidates = <String, dynamic>{};
    for (final entry in map.entries) {
      candidates[entry.key] = entry.value;
    }

    String pickString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = candidates[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
        if (value != null) return value.toString().trim();
      }
      return fallback;
    }

    final idValue = pickString(['id', 'orderId', 'order_id']);
    final requestName =
        pickString(['requestName', 'customerName', 'name', 'customer_name']);
    final phone = pickString([
      'phoneNumber',
      'phone',
      'customerPhone',
      'contactNumber',
      'contact_number'
    ]);
    final recipientPhone = pickString([
      'recepientNumber',
      'recipientPhone',
      'recipient_phone',
      'recepient_number'
    ]);
    final deliveryAddress =
        pickString(['deliveryAddress', 'address', 'delivery_address']);
    final destinationAddress = pickString(
        ['destinationAddress', 'destination', 'destination_address']);
    final deliveryType =
        pickString(['deliveryType', 'fuelType', 'fuel_type', 'product']);
    final quantityOil = pickString(
        ['quantityOil', 'litres', 'liters', 'quantity', 'quantity_litres']);
    final amount =
        pickString(['totalAmount', 'amount', 'total_amount', 'price']);
    final statusValue = pickString(['status', 'orderStatus', 'order_status'],
        fallback: 'awaiting_payment');
    final assigned =
        pickString(['assignedTo', 'assignee', 'assigned_to'], fallback: '');
    final stateValue = pickString(
        ['state', 'deliveryState', 'delivery_state', 'stateOfDelivery'],
        fallback: '');
    final distanceVal =
        pickString(['distanceKm', 'distance_km', 'distance'], fallback: '');
    final deliveryFeeVal = pickString(
        ['deliveryFee', 'delivery_fee', 'delivery_fee_total'],
        fallback: '');
    final deliveryPerKmVal = pickString(
        ['deliveryPerKm', 'delivery_per_km', 'per_km'],
        fallback: '');

    return ItemOrder(
      id: idValue,
      dateTime: pickString(['dateTime', 'createdAt', 'created_at', 'date'],
          fallback: ''),
      phoneNumber: phone,
      recepientNumber: recipientPhone,
      deliveryAddress: deliveryAddress,
      deliveryType: deliveryType,
      destinationAddress: destinationAddress,
      quantityOil: quantityOil,
      requestName: requestName,
      status: statusValue.isEmpty ? 'awaiting_payment' : statusValue,
      totalAmount: amount.isEmpty ? '0' : amount,
      assignedTo: assigned,
      state: stateValue,
      distanceKm: distanceVal,
      deliveryFee: deliveryFeeVal,
      deliveryPerKm: deliveryPerKmVal,
    );
  }
}
