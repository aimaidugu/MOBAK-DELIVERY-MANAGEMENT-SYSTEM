import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/constants.dart';
import 'package:delivery/itemorder.dart';
import 'package:delivery/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobak Petrol Supply & Logistics'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.add_circle_outline, size: 32),
                  title: const Text('Place fuel order'),
                  subtitle: const Text(
                      'Request petrol, diesel, or LPG delivery for your location.'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const _NewOrder()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewOrder extends ConsumerStatefulWidget {
  const _NewOrder();

  @override
  ConsumerState<_NewOrder> createState() => __NewOrderState();
}

class __NewOrderState extends ConsumerState<_NewOrder> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _litresController = TextEditingController(text: '0.0');
  final _destinationController = TextEditingController();
  final _distanceController = TextEditingController();
  final _recipientController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final Future<QuerySnapshot<Map<String, dynamic>>>
      _deliveryPricingFuture =
      FirebaseFirestore.instance.collection('delivery_pricing').get();
  String _selectedFuel = 'petrol';
  String _selectedState = 'Lagos';

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _litresController.dispose();
    _destinationController.dispose();
    _distanceController.dispose();
    _recipientController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final costsAsync = ref.watch(getCostsProvider);
    final statePricesAsync = ref.watch(getDeliveryStatePricesProvider);

    return costsAsync.when(
      data: (costs) {
        return statePricesAsync.when(
          data: (statePrices) {
            return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: _deliveryPricingFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }

                if (snap.hasError) {
                  debugPrint('Delivery pricing load failed: ${snap.error}');
                }

                final perKmMap = <String, double>{};
                for (final doc in snap.data?.docs ??
                    const <QueryDocumentSnapshot<Map<String, dynamic>>>[]) {
                  final data = doc.data();
                  final stateName = (data['state'] ?? '').toString().trim();
                  if (stateName.isEmpty) continue;
                  perKmMap[stateName] = normalizeCostValue(
                    data['per_km'] ?? data['perKm'] ?? data['perKmRate'] ?? 0.0,
                    defaultValue: 0.0,
                  );
                }

                final fuelType = normalizeFuelType(_selectedFuel);
                final litres = double.tryParse(_litresController.text) ?? 0.0;
                final perLitre = fuelType == 'petrol' ? costs.$1 : costs.$2;
                final selectedState = nigerianStates.contains(_selectedState)
                    ? _selectedState
                    : 'Lagos';
                final enteredDistance =
                    double.tryParse(_distanceController.text) ?? 0.0;
                final statePerKm = perKmMap[selectedState] ?? 0.0;
                final perKm = statePerKm > 0 ? statePerKm : costs.$3;
                final deliveryFee = (enteredDistance > 0 && perKm > 0)
                    ? calculateDeliveryFee(enteredDistance, perKm)
                    : (statePrices[selectedState] ?? 0.0);
                final fuelCost = litres * perLitre;
                final total = calculateOrderTotal(
                  fuelCost: fuelCost,
                  deliveryFee: deliveryFee,
                );

                return Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: const Text('New Order'),
                  ),
                  persistentFooterButtons: [
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          if (context.mounted) {
                            NotificationService.showNotificationToast(
                              context,
                              'Please fix the highlighted errors',
                              'Validation',
                              NotificationTypes.error,
                            );
                          }
                          return;
                        }

                        await ref.read(addOrderProvider(ItemOrder(
                          id: const Uuid().v4(),
                          dateTime:
                              DateTime.now().toIso8601String().split('T')[0],
                          phoneNumber: _numberController.text.trim(),
                          deliveryAddress: selectedState,
                          destinationAddress: _addressController.text.trim(),
                          deliveryType: fuelType,
                          quantityOil: _litresController.text.trim(),
                          recepientNumber: _recipientController.text.trim(),
                          requestName: _nameController.text.trim(),
                          status: 'awaiting_payment',
                          totalAmount: total.toStringAsFixed(2),
                          distanceKm: enteredDistance > 0
                              ? enteredDistance.toStringAsFixed(2)
                              : '',
                          deliveryFee: deliveryFee.toStringAsFixed(2),
                          deliveryPerKm:
                              perKm > 0 ? perKm.toStringAsFixed(2) : '',
                          state: selectedState,
                        )).future);

                        if (!context.mounted) return;
                        NotificationService.showNotificationToast(
                          context,
                          'Saved order successfully, you would be contacted shortly',
                          'order saved',
                          NotificationTypes.good,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 65),
                      ),
                      child: const Text('Create new order'),
                    ),
                  ],
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Fuel type',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: ['petrol', 'diesel'].map((type) {
                                      final selected = fuelType == type;
                                      final label = type == 'petrol'
                                          ? 'Petrol'
                                          : 'Diesel';
                                      return ChoiceChip(
                                        label: Text(label),
                                        selected: selected,
                                        onSelected: (_) {
                                          setState(() => _selectedFuel =
                                              normalizeFuelType(type));
                                        },
                                        selectedColor: Colors.amber.shade100,
                                        avatar: Icon(
                                          type == 'petrol'
                                              ? Icons.local_gas_station
                                              : Icons.oil_barrel,
                                          color: selected
                                              ? Colors.amber.shade900
                                              : Colors.grey,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Your name',
                            hint: 'Enter your name',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Name required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _numberController,
                            label: 'Phone number',
                            hint: 'Enter your number',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Phone required';
                              final pattern = RegExp(r'^[+\d\s-]{7,15}$');
                              if (!pattern.hasMatch(value.trim()))
                                return 'Invalid phone';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _litresController,
                            label: 'Litres needed',
                            hint: 'Enter litres required',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              final n = double.tryParse(value ?? '0');
                              if (n == null || n <= 0)
                                return 'Enter litres > 0';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: selectedState,
                            decoration: InputDecoration(
                              labelText: 'Delivery state',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            items: nigerianStates
                                .map((state) => DropdownMenuItem<String>(
                                      value: state,
                                      child: Text(state),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(
                                () => _selectedState = value ?? 'Lagos'),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _destinationController,
                            label: 'Delivery address',
                            hint: 'Enter delivery address',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Delivery address required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _recipientController,
                            label: 'Recipient phone',
                            hint: 'Enter recipient number',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Recipient phone required';
                              final pattern = RegExp(r'^[+\d\s-]{7,15}$');
                              if (!pattern.hasMatch(value.trim()))
                                return 'Invalid phone';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _addressController,
                            label: 'Your address',
                            hint: 'Enter your address',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Your address required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _distanceController,
                            label: 'Estimated distance (km, optional)',
                            hint: 'Enter estimated distance in kilometres',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return null;
                              final n = double.tryParse(value);
                              if (n == null || n < 0)
                                return 'Enter a valid distance';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Order summary',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'Fuel: ${fuelType[0].toUpperCase()}${fuelType.substring(1)}'),
                                Text('State: $selectedState'),
                                Text('Litres: ${litres.toStringAsFixed(1)}'),
                                Text(
                                    'Unit price: ₦${perLitre.toStringAsFixed(2)} / litre'),
                                Text(
                                    'Fuel total: ₦${fuelCost.toStringAsFixed(2)}'),
                                Text(
                                    'Delivery fee for $selectedState: ₦${deliveryFee.toStringAsFixed(2)}'),
                                if (perKm > 0)
                                  Text('Per km: ₦${perKm.toStringAsFixed(2)}'),
                                const SizedBox(height: 6),
                                Text(
                                  'Estimated total: ₦${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          error: (_, __) => const Center(child: Text('Failed to load')),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
      },
      error: (_, __) => const Center(child: Text('Failed to load')),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}
