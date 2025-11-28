import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../shop/controllers/banner_controller.dart';
import '../../../../data/repositories/product/produit_repository.dart';
import '../../../shop/models/banner_model.dart';
import '../../controllers/liste_etablissement_controller.dart';
import '../../controllers/user_controller.dart';
import 'edit_banner_widget/image_comparison.dart';
import 'edit_banner_widget/name_field.dart';
import 'edit_banner_widget/show_approve_dialog.dart';
import 'edit_banner_widget/show_reject_dialog.dart';
import 'edit_banner_widget/status_change_dialog.dart';
import 'widgets/image_placeholder.dart';
import 'widgets/image_preview.dart';
import 'widgets/link_selector.dart';
import 'widgets/local_image_preview.dart';

class EditBannerScreen extends StatelessWidget {
  final BannerModel banner;
  final bool isAdminView;

  const EditBannerScreen(
      {super.key, required this.banner, this.isAdminView = false});

  @override
  Widget build(BuildContext context) {
    final bannerController = Get.find<BannerController>();
    final produitRepository = Get.find<ProduitRepository>();
    final etablissementController = Get.find<ListeEtablissementController>();
    final userController = Get.find<UserController>();

    // Charger les données pour les dropdowns
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final products = await produitRepository.getAllProducts();
        bannerController.products.assignAll(products);
      } catch (e) {
        debugPrint('Erreur chargement produits: $e');
      }
      try {
        // Si gérant, charger uniquement son établissement
        if (userController.userRole == 'Gérant') {
          final gerantEtablissement = await etablissementController
              .getEtablissementUtilisateurConnecte();
          if (gerantEtablissement != null) {
            bannerController.establishments.assignAll([gerantEtablissement]);
            // Si le type de lien est "establishment" et qu'aucun lien n'est sélectionné, utiliser l'établissement du gérant
            if (banner.linkType == 'establishment' &&
                (banner.link == null || banner.link!.isEmpty)) {
              bannerController.selectedLinkId.value =
                  gerantEtablissement.id ?? '';
            }
          }
        } else {
          // Pour admin, charger tous les établissements
          final establishments =
              await etablissementController.getTousEtablissements();
          bannerController.establishments.assignAll(establishments);
        }
      } catch (e) {
        debugPrint('Erreur chargement établissements: $e');
      }
    });

    // Charger la bannière pour édition
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bannerController.loadBannerForEditing(banner);
    });

    return Scaffold(
      appBar: TAppBar(
        title: Text(
            isAdminView ? "Détails de la bannière" : "Modifier la bannière"),
      ),
      body: Obx(() => _buildBody(context, bannerController, isAdminView)),
    );
  }

  Widget _buildBody(
      BuildContext context, BannerController controller, bool isAdminView) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final dark = THelperFunctions.isDarkMode(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Image
              _buildImageSection(context, controller, isMobile, banner),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Nom de la bannière
              NameField(
                  controller: controller,
                  isAdminView: isAdminView,
                  banner: banner),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // Type de lien
              Obx(() {
                final currentValue = controller.selectedLinkType.value;
                final hasPendingLinkType = banner.pendingChanges != null &&
                    banner.pendingChanges!['link_type'] != null;
                final pendingLinkType = hasPendingLinkType
                    ? banner.pendingChanges!['link_type'].toString()
                    : null;
                final userController = Get.find<UserController>();
                final isGerant = userController.userRole == 'Gérant';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String?>(
                      value: currentValue.isEmpty ? null : currentValue,
                      decoration: InputDecoration(
                        labelText: 'Type de lien',
                        prefixIcon: const Icon(Iconsax.link),
                        filled: isAdminView,
                      ),
                      items: [
                        DropdownMenuItem(
                            value: null,
                            child: Text(
                              'Aucun lien',
                              style: TextStyle(
                                  color:
                                      dark ? Colors.white : TColors.eerieBlack),
                            )),
                        DropdownMenuItem(
                            value: 'product',
                            child: Text(
                              'Produit',
                              style: TextStyle(
                                  color:
                                      dark ? Colors.white : TColors.eerieBlack),
                            )),
                        DropdownMenuItem(
                          value: 'establishment',
                          child: Text(
                            'Établissement',
                            style: TextStyle(
                                color:
                                    dark ? Colors.white : TColors.eerieBlack),
                          ),
                        ),
                      ],
                      onChanged: isAdminView
                          ? null
                          : (value) {
                              controller.selectedLinkType.value = value ?? '';
                              if (value != banner.linkType) {
                                controller.selectedLinkId.value =
                                    ''; // Reset selection
                              }
                              // Si gérant sélectionne "établissement", définir automatiquement son établissement
                              if (isGerant &&
                                  value == 'establishment' &&
                                  controller.establishments.isNotEmpty) {
                                final gerantEtablissement = controller
                                    .establishments
                                    .firstWhereOrNull((e) => e.id != null);
                                if (gerantEtablissement != null) {
                                  controller.selectedLinkId.value =
                                      gerantEtablissement.id ?? '';
                                }
                              }
                            },
                    ),
                    // Afficher le type de lien modifié sous le dropdown
                    if (hasPendingLinkType && pendingLinkType != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Iconsax.edit,
                                size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nouveau type de lien:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pendingLinkType == 'product'
                                        ? 'Produit'
                                        : pendingLinkType == 'establishment'
                                            ? 'Établissement'
                                            : 'Aucun lien',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              }),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // Sélection du lien selon le type
              if (controller.selectedLinkType.value.isNotEmpty)
                LinkSelector(
                  controller: controller,
                  isAdminView: isAdminView,
                ),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // État actuel - modifiable par l'admin
              Obx(() {
                final status = controller.selectedStatus.value;
                String statusLabel;
                MaterialColor statusColor;
                IconData statusIcon;

                switch (status) {
                  case 'publiee':
                    statusLabel = 'Publiée';
                    statusColor = Colors.green;
                    statusIcon = Iconsax.tick_circle;
                    break;
                  case 'refusee':
                    statusLabel = 'Refusée';
                    statusColor = Colors.red;
                    statusIcon = Iconsax.close_circle;
                    break;
                  default:
                    statusLabel = 'En attente';
                    statusColor = Colors.orange;
                    statusIcon = Iconsax.clock;
                }

                return GestureDetector(
                  onTap: isAdminView
                      ? () =>
                          showStatusChangeDialog(context, banner, controller)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.shade200,
                        width: isAdminView ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'État actuel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: statusColor.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: statusColor.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAdminView
                                    ? 'Appuyez pour changer le statut'
                                    : 'Seul l\'administrateur peut modifier le statut.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isAdminView)
                          Icon(
                            Iconsax.arrow_right_3,
                            color: statusColor.shade700,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Boutons d'action
              if (isAdminView &&
                  banner.status == 'publiee' &&
                  banner.pendingChanges != null) ...[
                // Boutons pour approuver/refuser les modifications (Admin)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () =>
                                showApproveDialog(context, banner, controller),
                        icon: const Icon(Iconsax.tick_circle),
                        label: const Text('Approuver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.isLoading.value
                            ? null
                            : () =>
                                showRejectDialog(context, banner, controller),
                        icon: const Icon(Iconsax.close_circle),
                        label: const Text('Refuser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (!isAdminView) ...[
                // Bouton Modifier (seulement pour Gérant)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.updateBanner(banner.id),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Modifier la bannière'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    BannerController controller,
    bool isMobile,
    BannerModel banner,
  ) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image de la bannière',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Obx(() {
            final pickedImage = controller.pickedImage.value;
            final hasPendingImage = banner.pendingChanges != null &&
                banner.pendingChanges!['image_url'] != null;

            // Si admin et modifications en attente, afficher les deux images
            if (isAdminView && hasPendingImage) {
              return ImageComparison(
                currentImageUrl: controller.imageUrl.value,
                pendingImageUrl: banner.pendingChanges!['image_url'].toString(),
              );
            }

            // Sinon, affichage normal
            if (pickedImage != null) {
              return LocalImagePreview(imageFile: pickedImage);
            } else if (controller.imageUrl.value.isNotEmpty) {
              return ImagePreview(imageUrl: controller.imageUrl.value);
            } else {
              return ImagePlaceholder(
                  controller: controller, isMobile: isMobile);
            }
          }),
          const SizedBox(height: AppSizes.spaceBtwItems),
          if (!isAdminView)
            ElevatedButton.icon(
              onPressed: () => controller.pickImage(isMobile: isMobile),
              icon: const Icon(Iconsax.image),
              label: Text(
                  isMobile ? 'Changer l\'image (Mobile)' : 'Changer l\'image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
              ),
            ),
        ],
      ),
    );
  }
}
