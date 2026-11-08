import 'package:flutter/material.dart';
import 'theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final String selectedSection;
  final ValueChanged<String>? onSectionSelected;

  const AppScaffold({
    super.key,
    required this.child,
    this.title = '',
    this.selectedSection = 'Overview',
    this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarItems = [
      'Overview',
      'Orders',
      'Costs',
      'Notifications',
    ];

    final sidebarContent = Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Mobak',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ...sidebarItems.map((label) {
            final isSelected = label == selectedSection;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onSectionSelected?.call(label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        label == 'Overview'
                            ? Icons.dashboard_outlined
                            : label == 'Orders'
                                ? Icons.list_alt_outlined
                                : label == 'Costs'
                                    ? Icons.attach_money_outlined
                                    : Icons.notifications_outlined,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 10),
                      Text(label, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          const Divider(),
          const SizedBox(height: 12),
          Text('Operations', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );

    final appBar = AppBar(
      title: Text(title.isEmpty ? 'Admin' : title, style: Theme.of(context).textTheme.titleLarge),
      backgroundColor: AppColors.background,
      elevation: 0,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(Icons.notifications_none_outlined),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final useCompactLayout = constraints.maxWidth < 900;

        if (useCompactLayout) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: AppColors.surface,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: sidebarItems.map((label) {
                          final isSelected = label == selectedSection;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => onSectionSelected?.call(label),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  appBar,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              sidebarContent,
              Expanded(
                child: Column(
                  children: [
                    appBar,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;
  const KPICard({super.key, required this.title, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 20,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
