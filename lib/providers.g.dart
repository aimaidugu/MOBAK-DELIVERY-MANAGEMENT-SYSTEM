// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getAllOrders)
final getAllOrdersProvider = GetAllOrdersProvider._();

final class GetAllOrdersProvider extends $FunctionalProvider<
        AsyncValue<List<ItemOrder>>, List<ItemOrder>, FutureOr<List<ItemOrder>>>
    with $FutureModifier<List<ItemOrder>>, $FutureProvider<List<ItemOrder>> {
  GetAllOrdersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getAllOrdersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getAllOrdersHash();

  @$internal
  @override
  $FutureProviderElement<List<ItemOrder>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<ItemOrder>> create(Ref ref) {
    return getAllOrders(ref);
  }
}

String _$getAllOrdersHash() => r'51773769932288d4e41360f3107acbb57c13576d';

@ProviderFor(addOrder)
final addOrderProvider = AddOrderFamily._();

final class AddOrderProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  AddOrderProvider._(
      {required AddOrderFamily super.from, required ItemOrder super.argument})
      : super(
          retry: null,
          name: r'addOrderProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addOrderHash();

  @override
  String toString() {
    return r'addOrderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as ItemOrder;
    return addOrder(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddOrderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addOrderHash() => r'fd23ac6ab6a69a4a15297092d1eda57327047b2e';

final class AddOrderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, ItemOrder> {
  AddOrderFamily._()
      : super(
          retry: null,
          name: r'addOrderProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  AddOrderProvider call(
    ItemOrder data,
  ) =>
      AddOrderProvider._(argument: data, from: this);

  @override
  String toString() => r'addOrderProvider';
}

@ProviderFor(updateOrderStatus)
final updateOrderStatusProvider = UpdateOrderStatusFamily._();

final class UpdateOrderStatusProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  UpdateOrderStatusProvider._(
      {required UpdateOrderStatusFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'updateOrderStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateOrderStatusHash();

  @override
  String toString() {
    return r'updateOrderStatusProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return updateOrderStatus(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateOrderStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateOrderStatusHash() => r'b0fa9757b99174a6094d71eaa6e3421612423053';

final class UpdateOrderStatusFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<void>,
            (
              String,
              String,
            )> {
  UpdateOrderStatusFamily._()
      : super(
          retry: null,
          name: r'updateOrderStatusProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UpdateOrderStatusProvider call(
    String data,
    String id,
  ) =>
      UpdateOrderStatusProvider._(argument: (
        data,
        id,
      ), from: this);

  @override
  String toString() => r'updateOrderStatusProvider';
}

@ProviderFor(updateCost)
final updateCostProvider = UpdateCostFamily._();

final class UpdateCostProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  UpdateCostProvider._(
      {required UpdateCostFamily super.from, required double super.argument})
      : super(
          retry: null,
          name: r'updateCostProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateCostHash();

  @override
  String toString() {
    return r'updateCostProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as double;
    return updateCost(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateCostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateCostHash() => r'b8479475b7849f8f76e9f2e99a377b02d886d82f';

final class UpdateCostFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, double> {
  UpdateCostFamily._()
      : super(
          retry: null,
          name: r'updateCostProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UpdateCostProvider call(
    double newCost,
  ) =>
      UpdateCostProvider._(argument: newCost, from: this);

  @override
  String toString() => r'updateCostProvider';
}

@ProviderFor(assignOrder)
final assignOrderProvider = AssignOrderFamily._();

final class AssignOrderProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  AssignOrderProvider._(
      {required AssignOrderFamily super.from,
      required (
        String,
        String,
      )
          super.argument})
      : super(
          retry: null,
          name: r'assignOrderProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$assignOrderHash();

  @override
  String toString() {
    return r'assignOrderProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (
      String,
      String,
    );
    return assignOrder(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AssignOrderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assignOrderHash() => r'40866579fc7c371dd66515b91b245587daea669b';

final class AssignOrderFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<void>,
            (
              String,
              String,
            )> {
  AssignOrderFamily._()
      : super(
          retry: null,
          name: r'assignOrderProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  AssignOrderProvider call(
    String id,
    String assignee,
  ) =>
      AssignOrderProvider._(argument: (
        id,
        assignee,
      ), from: this);

  @override
  String toString() => r'assignOrderProvider';
}

@ProviderFor(addNotification)
final addNotificationProvider = AddNotificationFamily._();

final class AddNotificationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  AddNotificationProvider._(
      {required AddNotificationFamily super.from,
      required (
        String,
        String, {
        String orderId,
        String assignee,
      })
          super.argument})
      : super(
          retry: null,
          name: r'addNotificationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addNotificationHash();

  @override
  String toString() {
    return r'addNotificationProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (
      String,
      String, {
      String orderId,
      String assignee,
    });
    return addNotification(
      ref,
      argument.$1,
      argument.$2,
      orderId: argument.orderId,
      assignee: argument.assignee,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddNotificationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addNotificationHash() => r'3a27568a6fb9475f8db689c699ee353e03785d4c';

final class AddNotificationFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<void>,
            (
              String,
              String, {
              String orderId,
              String assignee,
            })> {
  AddNotificationFamily._()
      : super(
          retry: null,
          name: r'addNotificationProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  AddNotificationProvider call(
    String title,
    String message, {
    required String orderId,
    required String assignee,
  }) =>
      AddNotificationProvider._(argument: (
        title,
        message,
        orderId: orderId,
        assignee: assignee,
      ), from: this);

  @override
  String toString() => r'addNotificationProvider';
}

@ProviderFor(notificationsStream)
final notificationsStreamProvider = NotificationsStreamProvider._();

final class NotificationsStreamProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        Stream<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  NotificationsStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationsStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    return notificationsStream(ref);
  }
}

String _$notificationsStreamHash() =>
    r'ea1b96187e854f127da9e2e5f3c8da193d527ae7';

@ProviderFor(updateDeliveryCost)
final updateDeliveryCostProvider = UpdateDeliveryCostFamily._();

final class UpdateDeliveryCostProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  UpdateDeliveryCostProvider._(
      {required UpdateDeliveryCostFamily super.from,
      required double super.argument})
      : super(
          retry: null,
          name: r'updateDeliveryCostProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateDeliveryCostHash();

  @override
  String toString() {
    return r'updateDeliveryCostProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as double;
    return updateDeliveryCost(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateDeliveryCostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateDeliveryCostHash() =>
    r'2b588eba440b5c44bf27e954b61912ed6a77eece';

final class UpdateDeliveryCostFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, double> {
  UpdateDeliveryCostFamily._()
      : super(
          retry: null,
          name: r'updateDeliveryCostProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UpdateDeliveryCostProvider call(
    double newCost,
  ) =>
      UpdateDeliveryCostProvider._(argument: newCost, from: this);

  @override
  String toString() => r'updateDeliveryCostProvider';
}

@ProviderFor(updateDeliveryStatePrice)
final updateDeliveryStatePriceProvider = UpdateDeliveryStatePriceFamily._();

final class UpdateDeliveryStatePriceProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  UpdateDeliveryStatePriceProvider._(
      {required UpdateDeliveryStatePriceFamily super.from,
      required (
        String,
        double,
      )
          super.argument})
      : super(
          retry: null,
          name: r'updateDeliveryStatePriceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateDeliveryStatePriceHash();

  @override
  String toString() {
    return r'updateDeliveryStatePriceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (
      String,
      double,
    );
    return updateDeliveryStatePrice(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateDeliveryStatePriceProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateDeliveryStatePriceHash() =>
    r'9e0afa7b077618f4e2430b205b9f1ea3ed546274';

final class UpdateDeliveryStatePriceFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<void>,
            (
              String,
              double,
            )> {
  UpdateDeliveryStatePriceFamily._()
      : super(
          retry: null,
          name: r'updateDeliveryStatePriceProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UpdateDeliveryStatePriceProvider call(
    String state,
    double newCost,
  ) =>
      UpdateDeliveryStatePriceProvider._(argument: (
        state,
        newCost,
      ), from: this);

  @override
  String toString() => r'updateDeliveryStatePriceProvider';
}

@ProviderFor(updateDeliveryStatePerKm)
final updateDeliveryStatePerKmProvider = UpdateDeliveryStatePerKmFamily._();

final class UpdateDeliveryStatePerKmProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  UpdateDeliveryStatePerKmProvider._(
      {required UpdateDeliveryStatePerKmFamily super.from,
      required (
        String,
        double,
      )
          super.argument})
      : super(
          retry: null,
          name: r'updateDeliveryStatePerKmProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateDeliveryStatePerKmHash();

  @override
  String toString() {
    return r'updateDeliveryStatePerKmProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (
      String,
      double,
    );
    return updateDeliveryStatePerKm(
      ref,
      argument.$1,
      argument.$2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateDeliveryStatePerKmProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateDeliveryStatePerKmHash() =>
    r'709950cc6d9466a009651c2a80d8c724365b1ab8';

final class UpdateDeliveryStatePerKmFamily extends $Family
    with
        $FunctionalFamilyOverride<
            FutureOr<void>,
            (
              String,
              double,
            )> {
  UpdateDeliveryStatePerKmFamily._()
      : super(
          retry: null,
          name: r'updateDeliveryStatePerKmProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  UpdateDeliveryStatePerKmProvider call(
    String state,
    double perKm,
  ) =>
      UpdateDeliveryStatePerKmProvider._(argument: (
        state,
        perKm,
      ), from: this);

  @override
  String toString() => r'updateDeliveryStatePerKmProvider';
}

@ProviderFor(getDeliveryStatePerKm)
final getDeliveryStatePerKmProvider = GetDeliveryStatePerKmProvider._();

final class GetDeliveryStatePerKmProvider extends $FunctionalProvider<
        AsyncValue<Map<String, double>>,
        Map<String, double>,
        FutureOr<Map<String, double>>>
    with
        $FutureModifier<Map<String, double>>,
        $FutureProvider<Map<String, double>> {
  GetDeliveryStatePerKmProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getDeliveryStatePerKmProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getDeliveryStatePerKmHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, double>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, double>> create(Ref ref) {
    return getDeliveryStatePerKm(ref);
  }
}

String _$getDeliveryStatePerKmHash() =>
    r'a12842024a65601f787a09ea27d3986d1709d6e8';

@ProviderFor(getDeliveryStatePrices)
final getDeliveryStatePricesProvider = GetDeliveryStatePricesProvider._();

final class GetDeliveryStatePricesProvider extends $FunctionalProvider<
        AsyncValue<Map<String, double>>,
        Map<String, double>,
        FutureOr<Map<String, double>>>
    with
        $FutureModifier<Map<String, double>>,
        $FutureProvider<Map<String, double>> {
  GetDeliveryStatePricesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getDeliveryStatePricesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getDeliveryStatePricesHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, double>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, double>> create(Ref ref) {
    return getDeliveryStatePrices(ref);
  }
}

String _$getDeliveryStatePricesHash() =>
    r'59ec9de054ed6504e0f21d4421565c67c8e3c524';

@ProviderFor(getCost)
final getCostProvider = GetCostProvider._();

final class GetCostProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  GetCostProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getCostProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getCostHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return getCost(ref);
  }
}

String _$getCostHash() => r'2ff1420c163045076ccd494b4c5cd8809f3fecd5';

@ProviderFor(getDeliveryCost)
final getDeliveryCostProvider = GetDeliveryCostProvider._();

final class GetDeliveryCostProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  GetDeliveryCostProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getDeliveryCostProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getDeliveryCostHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return getDeliveryCost(ref);
  }
}

String _$getDeliveryCostHash() => r'ee5cbc5c2c569a2e4b70afc0ce94858c002ffadf';

@ProviderFor(getDieselCost)
final getDieselCostProvider = GetDieselCostProvider._();

final class GetDieselCostProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  GetDieselCostProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getDieselCostProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getDieselCostHash();

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    return getDieselCost(ref);
  }
}

String _$getDieselCostHash() => r'9cd91f68edbfb5168bc807c13341c9b157dfddf3';

@ProviderFor(getCosts)
final getCostsProvider = GetCostsProvider._();

final class GetCostsProvider extends $FunctionalProvider<
        AsyncValue<
            (
              double,
              double,
              double,
            )>,
        (
          double,
          double,
          double,
        ),
        FutureOr<
            (
              double,
              double,
              double,
            )>>
    with
        $FutureModifier<
            (
              double,
              double,
              double,
            )>,
        $FutureProvider<
            (
              double,
              double,
              double,
            )> {
  GetCostsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getCostsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getCostsHash();

  @$internal
  @override
  $FutureProviderElement<
      (
        double,
        double,
        double,
      )> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<
      (
        double,
        double,
        double,
      )> create(Ref ref) {
    return getCosts(ref);
  }
}

String _$getCostsHash() => r'66bbc6567611dd4257de492643096cc36150640d';
