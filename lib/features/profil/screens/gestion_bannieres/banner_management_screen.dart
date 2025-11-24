import 'package:caferesto/utils/constants/sizes.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:caferesto/features/shop/models/banner_model.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../shop/controllers/banner_controller.dart';
import '../../../../common/widgets/loading/loading_screen.dart';
import '../../viewmodels/banner_management_viewmodel.dart';
import 'add_banner_screen.dart';
import 'edit_banner_screen.dart';

class BannerManagementScreen extends StatelessWidget {
  const BannerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialiser les controllers
    Get.put(BannerController());
    final viewModel = Get.put(BannerManagementViewModel());

    return Scaffold(
      appBar: TAppBar(
        title: const Text("Gestion des bannières"),
      ),
      body: Column(
        children: [
          _buildTabs(context, viewModel),
          _buildSearchBar(context, viewModel),
          Expanded(child: _buildBody(context, viewModel)),
        ],
      ),
      floatingActionButton: viewModel.canManageBanners ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildTabs(BuildContext context, BannerManagementViewModel viewModel) {
    final dark = THelperFunctions.isDarkMode(context);

    return Obx(() => Container(
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: viewModel.tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.clock, size: 16),
                const SizedBox(width: 8),
                const Text('En attente'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${viewModel.enAttenteCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.tick_circle, size: 16),
                const SizedBox(width: 8),
                const Text('Publiée'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${viewModel.publieeCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.close_circle, size: 16),
                const SizedBox(width: 8),
                const Text('Refusée'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${viewModel.refuseeCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        labelColor: Colors.blue.shade600,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue.shade600,
      ),
    ));
  }

  Widget _buildBody(BuildContext context, BannerManagementViewModel viewModel) {
    return Obx(() {
      if (viewModel.isLoading) {
        return LoadingScreen(
          screenName: 'Bannières',
        );
      }

      final banners = viewModel.filteredBanners;
      
      if (banners.isEmpty) {
        return _buildEmptyState(viewModel);
      }

      return _buildBannerList(context, banners, viewModel);
    });
  }

  Widget _buildEmptyState(BannerManagementViewModel viewModel) {
    return Obx(() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.image, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Aucune bannière ${viewModel.getTabName(viewModel.selectedTabIndex.value).toLowerCase()}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildBannerList(BuildContext context, List<BannerModel> banners, BannerManagementViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refreshBanners,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        itemCount: banners.length,
        itemBuilder: (_, i) => _buildBannerCard(banners[i], context, viewModel),
      ),
    );
  }

  Widget _buildBannerCard(BannerModel banner, BuildContext context, BannerManagementViewModel viewModel) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: dark ? TColors.eerieBlack : TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildBannerImage(banner),
        title: Text(
          banner.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerSubtitle(banner),
            const SizedBox(height: 4),
            _buildStatusChip(banner, viewModel),
            // Afficher les modifications en attente pour l'admin
            if (viewModel.isAdmin && viewModel.hasPendingChanges(banner)) ...[
              const SizedBox(height: 8),
              _buildPendingChangesIndicator(banner, viewModel),
            ],
          ],
        ),
        trailing: viewModel.isAdmin
            ? (viewModel.hasPendingChanges(banner)
                ? _buildPendingChangesActions(banner, viewModel)
                : null)
            : viewModel.isGerant
                ? IconButton(
                    icon: const Icon(Iconsax.more),
                    onPressed: () => _showBannerOptions(context, banner, viewModel),
                  )
                : null,
        onTap: viewModel.isAdmin
            ? () {
                // Admin peut cliquer pour voir les détails et changer le statut
                viewModel.loadBannerForEditing(banner);
                Get.to(() => EditBannerScreen(banner: banner, isAdminView: true));
              }
            : viewModel.isGerant
                ? () => _showBannerOptions(context, banner, viewModel)
                : null,
      ),
    );
  }

  Widget _buildStatusChip(BannerModel banner, BannerManagementViewModel viewModel) {
    final statusColor = viewModel.getStatusColor(banner.status);
    final statusLabel = viewModel.getStatusLabel(banner.status);
    
    IconData statusIcon;
    switch (banner.status) {
      case 'publiee':
        statusIcon = Iconsax.tick_circle;
        break;
      case 'refusee':
        statusIcon = Iconsax.close_circle;
        break;
      default:
        statusIcon = Iconsax.clock;
    }

    return GestureDetector(
      onTap: viewModel.isAdmin
          ? () => _showStatusChangeDialog(banner, viewModel)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: viewModel.isAdmin ? statusColor.shade300 : statusColor.shade200,
            width: viewModel.isAdmin ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 12, color: statusColor.shade700),
            const SizedBox(width: 4),
            Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor.shade700,
              ),
            ),
            if (viewModel.isAdmin) ...[
              const SizedBox(width: 4),
              Icon(
                Iconsax.arrow_down_1,
                size: 10,
                color: statusColor.shade700,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStatusChangeDialog(BannerModel banner, BannerManagementViewModel viewModel) {
    final currentStatus = banner.status;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Changer le statut"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Bannière: ${banner.name}"),
            const SizedBox(height: 16),
            const Text("Sélectionner le nouveau statut:"),
            const SizedBox(height: 16),
            _buildStatusOption('en_attente', 'En attente', Colors.orange, Iconsax.clock, currentStatus, banner, viewModel),
            const SizedBox(height: 8),
            _buildStatusOption('publiee', 'Publiée', Colors.green, Iconsax.tick_circle, currentStatus, banner, viewModel),
            const SizedBox(height: 8),
            _buildStatusOption('refusee', 'Refusée', Colors.red, Iconsax.close_circle, currentStatus, banner, viewModel),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Annuler"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    String status,
    String label,
    MaterialColor color,
    IconData icon,
    String currentStatus,
    BannerModel banner,
    BannerManagementViewModel viewModel,
  ) {
    final isSelected = status == currentStatus;
    
    return InkWell(
      onTap: isSelected
          ? null
          : () {
              Get.back();
              viewModel.updateBannerStatus(banner.id, status);
            },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.shade100 : color.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color.shade300 : color.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: color.shade700,
                ),
              ),
            ),
            if (isSelected)
              Icon(Iconsax.tick_circle, color: color.shade700, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerImage(BannerModel banner) {
    return Container(
      width: 80,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          banner.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Iconsax.image, color: Colors.grey[400], size: 24),
          loadingBuilder: (context, child, loading) {
            if (loading == null) return child;
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 2));
          },
        ),
      ),
    );
  }

  Widget _buildBannerSubtitle(BannerModel banner) {
    String subtitle = '';
    if (banner.linkType != null && banner.linkType!.isNotEmpty) {
      switch (banner.linkType) {
        case 'product':
          subtitle = 'Produit';
          break;
        case 'category':
          subtitle = 'Catégorie';
          break;
        case 'establishment':
          subtitle = 'Établissement';
          break;
        default:
          subtitle = 'Aucun lien';
      }
    } else {
      subtitle = 'Aucun lien';
    }

    return Text(
      subtitle,
      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
    );
  }

  Widget _buildFloatingActionButton() => FloatingActionButton(
        onPressed: () => Get.to(() => const AddBannerScreen()),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Iconsax.additem, size: 28),
      );

  void _showBannerOptions(BuildContext context, BannerModel banner, BannerManagementViewModel viewModel) {
    if (!viewModel.isGerant) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildBottomSheetContent(context, banner, viewModel),
    );
  }

  Widget _buildBottomSheetContent(BuildContext context, BannerModel banner, BannerManagementViewModel viewModel) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? TColors.eerieBlack : TColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomSheetHeader(banner, viewModel),
          const SizedBox(height: 16),
          _buildActionButtons(context, banner, viewModel),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Annuler"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetHeader(BannerModel banner, BannerManagementViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildBannerImage(banner),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _buildBannerSubtitle(banner),
                const SizedBox(height: 8),
                _buildStatusChip(banner, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BannerModel banner, BannerManagementViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                viewModel.loadBannerForEditing(banner);
                Get.to(() => EditBannerScreen(banner: banner));
              },
              icon: const Icon(Iconsax.edit, size: 20),
              label: const Text("Éditer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteDialog(context, banner, viewModel),
              icon: const Icon(Iconsax.trash, size: 20),
              label: const Text("Supprimer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, BannerModel banner, BannerManagementViewModel viewModel) {
    Navigator.pop(context);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber),
            SizedBox(width: 12),
            Text("Confirmer la suppression"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Supprimer la bannière \"${banner.name}\" ?"),
            const SizedBox(height: 8),
            Text(
              "Cette action est irréversible.",
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Fermer le dialog de confirmation
              await viewModel.deleteBanner(banner.id);
              // Le snackbar de succès sera affiché par le contrôleur
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text("Supprimer"),
          )
        ],
      ),
    );
  }

  /// Widget pour afficher l'indicateur de modifications en attente
  Widget _buildPendingChangesIndicator(BannerModel banner, BannerManagementViewModel viewModel) {
    return InkWell(
      onTap: () => _showPendingChangesDetails(banner, viewModel),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.edit, size: 16, color: Colors.blue.shade700),
            const SizedBox(width: 6),
            Text(
              'Modifications en attente',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Iconsax.arrow_right_2, size: 14, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  /// Widget pour les boutons d'action sur les modifications en attente (Admin)
  Widget _buildPendingChangesActions(BannerModel banner, BannerManagementViewModel viewModel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Iconsax.tick_circle, color: Colors.green.shade600),
          tooltip: 'Approuver les modifications',
          onPressed: () => _showApprovePendingChangesDialog(banner, viewModel),
        ),
        IconButton(
          icon: Icon(Iconsax.close_circle, color: Colors.red.shade600),
          tooltip: 'Refuser les modifications',
          onPressed: () => _showRejectPendingChangesDialog(banner, viewModel),
        ),
        IconButton(
          icon: const Icon(Iconsax.eye),
          tooltip: 'Voir les modifications',
          onPressed: () => _showPendingChangesDetails(banner, viewModel),
        ),
      ],
    );
  }

  /// Dialog pour afficher les détails des modifications en attente
  void _showPendingChangesDetails(BannerModel banner, BannerManagementViewModel viewModel) {
    if (banner.pendingChanges == null) return;

    final pendingChanges = banner.pendingChanges!;
    final currentBanner = banner;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Iconsax.edit, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            const Text("Modifications en attente"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Bannière: ${banner.name}",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildChangeComparison(
                "Nom",
                currentBanner.name,
                pendingChanges['name']?.toString() ?? currentBanner.name,
              ),
              const SizedBox(height: 12),
              _buildImageComparison(
                currentBanner.imageUrl,
                pendingChanges['image_url']?.toString(),
              ),
              if (pendingChanges['link'] != null || pendingChanges['link_type'] != null) ...[
                const SizedBox(height: 12),
                _buildChangeComparison(
                  "Lien",
                  "${currentBanner.linkType ?? 'Aucun'} - ${currentBanner.link ?? 'Aucun'}",
                  "${pendingChanges['link_type'] ?? currentBanner.linkType ?? 'Aucun'} - ${pendingChanges['link'] ?? currentBanner.link ?? 'Aucun'}",
                ),
              ],
              if (banner.pendingChangesRequestedAt != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  "Demandé le: ${_formatDate(banner.pendingChangesRequestedAt!)}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Fermer"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _showApprovePendingChangesDialog(banner, viewModel);
            },
            icon: const Icon(Iconsax.tick_circle, size: 18),
            label: const Text("Approuver"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeComparison(String label, String current, String pending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Actuel:",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      current,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nouveau:",
                      style: TextStyle(fontSize: 11, color: Colors.blue.shade600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pending,
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageComparison(String currentImageUrl, String? pendingImageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Image",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Actuelle:",
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        currentImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Iconsax.image, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nouvelle:",
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: pendingImageUrl != null
                          ? Image.network(
                              pendingImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Iconsax.image, color: Colors.grey[400]),
                            )
                          : Center(
                              child: Text(
                                "Aucun changement",
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  /// Dialog pour confirmer l'approbation des modifications
  void _showApprovePendingChangesDialog(BannerModel banner, BannerManagementViewModel viewModel) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Iconsax.tick_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text("Approuver les modifications"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Approuver les modifications pour la bannière \"${banner.name}\" ?"),
            const SizedBox(height: 8),
            Text(
              "Les modifications seront appliquées immédiatement.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await viewModel.approvePendingChanges(banner.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text("Approuver"),
          ),
        ],
      ),
    );
  }

  /// Dialog pour confirmer le refus des modifications
  void _showRejectPendingChangesDialog(BannerModel banner, BannerManagementViewModel viewModel) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Iconsax.close_circle, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text("Refuser les modifications"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Refuser les modifications pour la bannière \"${banner.name}\" ?"),
            const SizedBox(height: 8),
            Text(
              "Les modifications en attente seront supprimées.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await viewModel.rejectPendingChanges(banner.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text("Refuser"),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, BannerManagementViewModel viewModel) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: viewModel.updateSearch,
              decoration: InputDecoration(
                hintText: "Rechercher une bannière...",
                prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: dark ? TColors.eerieBlack : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
