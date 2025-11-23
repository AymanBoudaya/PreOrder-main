import 'package:caferesto/features/profil/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class PeriodFilter extends StatelessWidget {
  final bool dark = false;
  final DashboardController controller;
  const PeriodFilter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusSm),
        border: Border.all(
          color: TColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.calendar, size: 20, color: TColors.primary),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Filtre par période',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Options de période rapide
          Wrap(
            children: [
              const Text('Période rapide: '),
              const SizedBox(width: AppSizes.sm),
              DropdownButton<String>(
                value: controller.useCustomDateRange.value
                    ? 'custom'
                    : controller.selectedPeriod.value,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(value: '7', child: Text('7 jours')),
                  const DropdownMenuItem(value: '30', child: Text('30 jours')),
                  const DropdownMenuItem(value: '90', child: Text('90 jours')),
                  const DropdownMenuItem(
                      value: 'custom', child: Text('Personnalisé')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    if (value == 'custom') {
                      controller.useCustomDateRange.value = true;
                    } else {
                      controller.updatePeriod(value);
                    }
                  }
                },
              ),
            ],
          ),
          // Filtre par dates personnalisées
          Obx(() {
            if (controller.useCustomDateRange.value) {
              return Column(
                children: [
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  controller.startDate.value ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              controller.startDate.value = pickedDate;
                              if (controller.endDate.value != null) {
                                controller.updateCustomDateRange(
                                  controller.startDate.value,
                                  controller.endDate.value,
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.sm),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.calendar_1, size: 16),
                                const SizedBox(width: AppSizes.xs),
                                Text(
                                  controller.startDate.value != null
                                      ? '${controller.startDate.value!.day}/${controller.startDate.value!.month}/${controller.startDate.value!.year}'
                                      : 'Date de début',
                                  style: TextStyle(
                                    color: controller.startDate.value != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      const Text('à'),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate:
                                  controller.endDate.value ?? DateTime.now(),
                              firstDate:
                                  controller.startDate.value ?? DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              controller.endDate.value = pickedDate;
                              if (controller.startDate.value != null) {
                                controller.updateCustomDateRange(
                                  controller.startDate.value,
                                  controller.endDate.value,
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.sm),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.calendar_1, size: 16),
                                const SizedBox(width: AppSizes.xs),
                                Text(
                                  controller.endDate.value != null
                                      ? '${controller.endDate.value!.day}/${controller.endDate.value!.month}/${controller.endDate.value!.year}'
                                      : 'Date de fin',
                                  style: TextStyle(
                                    color: controller.endDate.value != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      if (controller.startDate.value != null &&
                          controller.endDate.value != null)
                        IconButton(
                          icon: const Icon(Iconsax.close_circle),
                          onPressed: () => controller.clearCustomDateRange(),
                          tooltip: 'Effacer',
                        ),
                    ],
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
