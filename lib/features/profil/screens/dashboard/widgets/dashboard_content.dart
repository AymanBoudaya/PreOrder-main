import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/dashboard_controller.dart';
import 'main_stats_card.dart';
import 'orders_by_day.dart';
import 'orders_by_status_chart.dart';
import 'period_filter.dart';
import 'pickup_hours.dart';
import 'revenue_chart.dart';
import 'system_stats.dart';
import 'top_product_widget.dart';
import 'top_users.dart';

class DashboardContent extends StatelessWidget {
  final DashboardController controller;
  final bool dark;

  const DashboardContent(
      {super.key, required this.controller, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.stats.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final stats = controller.stats.value;
      if (stats == null) {
        return const Center(child: Text('Aucune statistique disponible'));
      }

      return RefreshIndicator(
        onRefresh: controller.loadDashboardStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtre de période
              PeriodFilter(controller: controller),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Cartes de statistiques principales
              MainStatsCard(stats: stats, dark: dark, isAdmin: true),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Graphiques et statistiques détaillées
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    // Desktop layout
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              RevenueChart(stats: stats, dark: dark),
                              const SizedBox(height: AppSizes.spaceBtwSections),
                              OrdersByStatusChart(stats: stats, dark: dark),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceBtwItems),
                        Expanded(
                          child: Column(
                            children: [
                              TopProductsWidget(stats: stats, dark: dark),
                              const SizedBox(height: AppSizes.spaceBtwSections),
                              SystemStats(stats: stats, dark: dark),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Mobile layout
                    return Column(
                      children: [
                        RevenueChart(stats: stats, dark: dark),
                        const SizedBox(height: AppSizes.spaceBtwSections),
                        OrdersByStatusChart(stats: stats, dark: dark),
                        const SizedBox(height: AppSizes.spaceBtwSections),
                        TopProductsWidget(
                          stats: stats,
                          dark: dark,
                        ),
                        const SizedBox(height: AppSizes.spaceBtwSections),
                        SystemStats(stats: stats, dark: dark),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Statistiques par jour et heures de pickup
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    // Desktop layout
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: OrdersByDay(stats: stats, dark: dark),
                        ),
                        const SizedBox(width: AppSizes.spaceBtwItems),
                        Expanded(
                          child: PickupHours(stats: stats, dark: dark),
                        ),
                      ],
                    );
                  } else {
                    // Mobile layout
                    return Column(
                      children: [
                        OrdersByDay(stats: stats, dark: dark),
                        const SizedBox(height: AppSizes.spaceBtwSections),
                        PickupHours(stats: stats, dark: dark),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Utilisateurs les plus fidèles
              TopUsers(stats: stats, dark: dark),
            ],
          ),
        ),
      );
    });
  }
}
