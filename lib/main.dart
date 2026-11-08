import 'package:delivery/auth.dart';
import 'package:delivery/contact.dart';
import 'package:delivery/firebase_options.dart';
import 'package:delivery/home.dart';
import 'package:delivery/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery/ui/theme.dart';
import 'package:delivery/screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("Firebase Project: ${Firebase.app().options.projectId}");
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      routes: {
        '/admin-dashboard': (context) => const AdminDashboard(),
      },
      home: const Scaffold(body: MainAp()),
    );
  }
}

class MainAp extends ConsumerWidget {
  const MainAp({super.key});

  void _openRoute(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        switch (index) {
          case 0:
            return AuthView();
          case 1:
            return const HomeView();
          case 2:
            return const ContactView();
          case 3:
            return const AdminDashboard();
          default:
            return const ContactView();
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costsAsync = ref.watch(getCostsProvider);

    return costsAsync.when(
      data: (costs) {
        final petrolPrice = costs.$1;
        final dieselPrice = costs.$2;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF071D13).withValues(alpha: 0.5),
                        const Color(0xFF0A2A1F).withValues(alpha: 0.7),
                        const Color(0xFF091B14).withValues(alpha: 0.82),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 960;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF69F59B), Color(0xFF1FBF72)],
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'M',
                                            style: TextStyle(
                                              color: Color(0xFF072D1E),
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'MOBAK',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.3,
                                            ),
                                          ),
                                          Text(
                                            'SUPPLIERS & LOGISTICS',
                                            style: TextStyle(
                                              color: Color(0xFFBDEAC8),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: isWide ? 760 : double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: const Color(0xFFFFD98A).withValues(alpha: 0.6)),
                                    ),
                                    child: const Text(
                                      'Trusted fuel retail operations',
                                      style: TextStyle(
                                        color: Color(0xFFFFE7AE),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'Petrol supply and logistics management for homes, fleets, and businesses.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 50,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'MOBAK helps customers place fuel orders, track delivery requests, and manage petrol pricing and dispatch operations for reliable service in Maiduguri, Nigeria.',
                                    style: TextStyle(
                                      color: Color(0xFFE9F7F0),
                                      fontSize: 18,
                                      height: 1.7,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 12,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _openRoute(context, 1),
                                        icon: const Icon(Icons.local_gas_station_rounded),
                                        label: const Text('Place order'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF7CE3A8),
                                          foregroundColor: const Color(0xFF081F15),
                                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () => _openRoute(context, 0),
                                        icon: const Icon(Icons.lock_open_rounded),
                                        label: const Text('Admin login'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(color: Colors.white70),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () => _openRoute(context, 2),
                                        icon: const Icon(Icons.mail_outline_rounded),
                                        label: const Text('Contact us'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(color: Colors.white70),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 44),
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _PriceStatCard(
                                  label: 'PETROL',
                                  value: '₦${petrolPrice.toStringAsFixed(0)}',
                                  suffix: 'per litre',
                                  accent: const Color(0xFF79F0A6),
                                ),
                                _PriceStatCard(
                                  label: 'DIESEL',
                                  value: '₦${dieselPrice.toStringAsFixed(0)}',
                                  suffix: 'per litre',
                                  accent: const Color(0xFF7CD6FF),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              spacing: 18,
                              runSpacing: 18,
                              children: [
                                _FeatureTile(
                                  icon: Icons.flash_on_rounded,
                                  title: 'Fast service',
                                  subtitle: 'Quick order placement and dispatch updates.',
                                ),
                                _FeatureTile(
                                  icon: Icons.verified_rounded,
                                  title: 'Quality assured',
                                  subtitle: 'Dependable pricing and service standards.',
                                ),
                                _FeatureTile(
                                  icon: Icons.shield_rounded,
                                  title: 'Safe & reliable',
                                  subtitle: 'Built for secure retail and customer confidence.',
                                ),
                              ],
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
        );
      },
      error: (_, __) => Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF071D13).withValues(alpha: 0.5),
                      const Color(0xFF0A2A1F).withValues(alpha: 0.7),
                      const Color(0xFF091B14).withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),
            ),
            const SafeArea(
              child: Center(
                child: Text(
                  'Unable to load fuel pricing',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }
}

class _PriceStatCard extends StatelessWidget {
  const _PriceStatCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.accent,
  });

  final String label;
  final String value;
  final String suffix;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                suffix,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF67E6A0).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF7AE4A3)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFE7F5EC),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
