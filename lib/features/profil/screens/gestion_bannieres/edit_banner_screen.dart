import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../shop/controllers/banner_controller.dart';
import '../../../../data/repositories/product/produit_repository.dart';
import '../../../shop/models/banner_model.dart';
import '../../../shop/models/etablissement_model.dart';
import '../../controllers/liste_etablissement_controller.dart';
import '../../controllers/user_controller.dart';
import 'widgets/image_placeholder.dart';
import 'widgets/image_preview.dart';
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
      body: Obx(() => _buildBody(context, bannerController)),
    );
  }

  Widget _buildBody(BuildContext context, BannerController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

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
              _buildNameField(context, controller, isAdminView, banner),
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
                      items: const [
                        DropdownMenuItem(
                            value: null, child: Text('Aucun lien')),
                        DropdownMenuItem(
                            value: 'product', child: Text('Produit')),
                        DropdownMenuItem(
                          value: 'establishment',
                          child: Text('Établissement'),
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
                _buildLinkSelector(context, controller, isAdminView, banner),
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
                          _showStatusChangeDialog(context, banner, controller)
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
                                _showApproveDialog(context, banner, controller),
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
                                _showRejectDialog(context, banner, controller),
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

  Widget _buildNameField(
    BuildContext context,
    BannerController controller,
    bool isAdminView,
    BannerModel banner,
  ) {
    final hasPendingName =
        banner.pendingChanges != null && banner.pendingChanges!['name'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.nameController,
          readOnly: isAdminView,
          decoration: InputDecoration(
            labelText: 'Nom de la bannière',
            prefixIcon: const Icon(Iconsax.text),
            filled: isAdminView,
          ),
          validator: (value) {
            if (!isAdminView && (value == null || value.isEmpty)) {
              return 'Veuillez entrer un nom';
            }
            return null;
          },
        ),
        // Afficher le nom modifié sous le TextField
        if (hasPendingName) ...[
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
                Icon(Iconsax.edit, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nouveau nom:',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        banner.pendingChanges!['name'].toString(),
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
              return _buildImageComparison(
                context,
                controller.imageUrl.value,
                banner.pendingChanges!['image_url'].toString(),
              );
            }

            // Sinon, affichage normal
            if (pickedImage != null) {
              return LocalImagePreview(imageFile : pickedImage);
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
              label: Text(isMobile
                  ? 'Changer l\'image (Mobile)'
                  : 'Changer l\'image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
              ),
            ),
        ],
      ),
    );
  }

  

  void _showStatusChangeDialog(
      BuildContext context, BannerModel banner, BannerController controller) {
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
            _buildStatusOption('en_attente', 'En attente', Colors.orange,
                Iconsax.clock, currentStatus, banner, controller),
            const SizedBox(height: 8),
            _buildStatusOption('publiee', 'Publiée', Colors.green,
                Iconsax.tick_circle, currentStatus, banner, controller),
            const SizedBox(height: 8),
            _buildStatusOption('refusee', 'Refusée', Colors.red,
                Iconsax.close_circle, currentStatus, banner, controller),
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
    BannerController controller,
  ) {
    final isSelected = status == currentStatus;

    return InkWell(
      onTap: isSelected
          ? null
          : () {
              Get.back();
              controller.updateBannerStatus(banner.id, status);
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

  /// Widget pour afficher la comparaison des images (ancienne vs nouvelle)
  Widget _buildImageComparison(
    BuildContext context,
    String currentImageUrl,
    String pendingImageUrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image actuelle
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image actuelle',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              child: CachedNetworkImage(
                imageUrl: currentImageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 40),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Nouvelle image
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.arrow_down_2,
                    size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 4),
                Text(
                  'Nouvelle image',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                border: Border.all(color: Colors.blue.shade300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                child: CachedNetworkImage(
                  imageUrl: pendingImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, size: 40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLinkSelector(
    BuildContext context,
    BannerController controller,
    bool isAdminView,
    BannerModel banner,
  ) {
    return Obx(() {
      // Déterminer le type de lien à afficher : priorité au type dans pendingChanges si présent
      final pendingLinkType = banner.pendingChanges != null
          ? banner.pendingChanges!['link_type']?.toString()
          : null;
      final linkType = pendingLinkType ?? controller.selectedLinkType.value;

      if (linkType.isEmpty) return const SizedBox.shrink();

      if (linkType == 'product') {
        final products = controller.products;
        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Aucun produit disponible',
                style: TextStyle(color: Colors.grey)),
          );
        }

        final selectedValue = controller.selectedLinkId.value;
        final isValidValue = selectedValue.isNotEmpty &&
            products.any((p) => p.id == selectedValue);

        // Vérifier si une modification est en attente pour un produit
        // Soit le type de lien a changé vers 'product', soit le produit a changé (même type)
        final hasPendingLink = banner.pendingChanges != null &&
            (banner.pendingChanges!['link_type'] == 'product' ||
                (banner.pendingChanges!['link'] != null &&
                    linkType == 'product'));
        final pendingLinkId =
            hasPendingLink && banner.pendingChanges!['link'] != null
                ? banner.pendingChanges!['link']?.toString()
                : null;
        final pendingProduct = pendingLinkId != null && pendingLinkId.isNotEmpty
            ? products.firstWhereOrNull((p) => p.id == pendingLinkId)
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: isValidValue ? selectedValue : null,
              decoration: InputDecoration(
                labelText: 'Sélectionner un produit',
                prefixIcon: const Icon(Iconsax.shop),
                filled: isAdminView,
              ),
              items: products.map((product) {
                return DropdownMenuItem(
                  value: product.id,
                  child: Text(product.name),
                );
              }).toList(),
              onChanged: isAdminView
                  ? null
                  : (value) {
                      controller.selectedLinkId.value = value ?? '';
                    },
            ),
            // Afficher le nouveau produit sélectionné sous le dropdown
            if (hasPendingLink && pendingProduct != null) ...[
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
                    Icon(Iconsax.edit, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouveau produit sélectionné:',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pendingProduct.name,
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
      } else if (linkType == 'establishment') {
        final userController = Get.find<UserController>();
        final isGerant = userController.userRole == 'Gérant';

        final establishments =
            controller.establishments.where((e) => e.id != null).toList();
        if (establishments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Aucun établissement disponible',
                style: TextStyle(color: Colors.grey)),
          );
        }

        // Pour le gérant, récupérer son établissement par défaut
        Etablissement? gerantEtablissement;
        if (isGerant && establishments.isNotEmpty) {
          gerantEtablissement = establishments.first;
          // Définir automatiquement l'établissement du gérant si pas encore défini
          if (controller.selectedLinkId.value.isEmpty && !isAdminView) {
            controller.selectedLinkId.value = gerantEtablissement.id ?? '';
          }
        }

        final selectedValue = controller.selectedLinkId.value;
        final isValidValue = selectedValue.isNotEmpty &&
            establishments.any((e) => e.id == selectedValue);

        // Vérifier si une modification est en attente pour un établissement
        // Soit le type de lien a changé vers 'establishment', soit l'établissement a changé (même type)
        final hasPendingLink = banner.pendingChanges != null &&
            (banner.pendingChanges!['link_type'] == 'establishment' ||
                (banner.pendingChanges!['link'] != null &&
                    linkType == 'establishment'));
        final pendingLinkId =
            hasPendingLink && banner.pendingChanges!['link'] != null
                ? banner.pendingChanges!['link']?.toString()
                : null;
        final pendingEstablishment =
            pendingLinkId != null && pendingLinkId.isNotEmpty
                ? establishments.firstWhereOrNull((e) => e.id == pendingLinkId)
                : null;

        // Déterminer l'établissement actuel à afficher
        final currentEstablishment = isValidValue
            ? establishments.firstWhere((e) => e.id == selectedValue)
            : gerantEtablissement;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ne pas afficher le dropdown pour le gérant, afficher directement l'établissement
            if (isGerant && !isAdminView) ...[
              if (currentEstablishment != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.home, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Établissement',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentEstablishment.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              // Pour l'admin, afficher le dropdown
              DropdownButtonFormField<String>(
                value: isValidValue ? selectedValue : null,
                decoration: InputDecoration(
                  labelText: 'Sélectionner un établissement',
                  prefixIcon: const Icon(Iconsax.home),
                  filled: isAdminView,
                ),
                items: establishments.map((establishment) {
                  return DropdownMenuItem(
                    value: establishment.id!,
                    child: Text(establishment.name),
                  );
                }).toList(),
                onChanged: isAdminView
                    ? null
                    : (value) {
                        controller.selectedLinkId.value = value ?? '';
                      },
              ),
            ],
            // Afficher le nouvel établissement sélectionné sous le dropdown/champ
            if (hasPendingLink && pendingEstablishment != null) ...[
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
                    Icon(Iconsax.edit, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouvel établissement sélectionné:',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pendingEstablishment.name,
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
      }

      return const SizedBox.shrink();
    });
  }

  void _showApproveDialog(
    BuildContext context,
    BannerModel banner,
    BannerController controller,
  ) {
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
        content: Text(
            "Approuver les modifications pour la bannière \"${banner.name}\" ?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              Get.back();
              await controller.approvePendingChanges(banner.id);
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

  void _showRejectDialog(
    BuildContext context,
    BannerModel banner,
    BannerController controller,
  ) {
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
        content: Text(
            "Refuser les modifications pour la bannière \"${banner.name}\" ?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              Get.back();
              await controller.rejectPendingChanges(banner.id);
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
}
