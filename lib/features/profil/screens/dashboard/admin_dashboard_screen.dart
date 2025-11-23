import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/dashboard_controller.dart';
import 'dashboard_side_menu.dart';
import 'widgets/dashboard_content.dart';


class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TAppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => controller.loadDashboardStats(),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Sur mobile, masquer le menu latéral
          if (constraints.maxWidth < 900) {
            return DashboardContent(controller: controller, dark: dark);
          }

          // Sur desktop, afficher le menu latéral
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menu latéral
              const DashboardSideMenu(
                currentRoute: 'dashboard',
                isAdmin: true,
              ),
              // Contenu du dashboard
              Expanded(
                child: DashboardContent(controller: controller, dark: dark),
              ),
            ],
          );
        },
      ),
    );
  }
}
