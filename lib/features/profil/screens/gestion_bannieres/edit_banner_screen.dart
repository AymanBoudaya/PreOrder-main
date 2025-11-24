import 'dart:typed_data';
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
import '../../controllers/liste_etablissement_controller.dart';

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

    // Charger les données pour les dropdowns
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final products = await produitRepository.getAllProducts();
        bannerController.products.assignAll(products);
      } catch (e) {
        debugPrint('Erreur chargement produits: $e');
      }
      try {
        final establishments =
            await etablissementController.getTousEtablissements();
        bannerController.establishments.assignAll(establishments);
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
              _buildImageSection(context, controller, isMobile),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Nom de la bannière
              TextFormField(
                controller: controller.nameController,
                readOnly: isAdminView, // Lecture seule pour admin
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
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // Type de lien
              Obx(() {
                final currentValue = controller.selectedLinkType.value;
                return DropdownButtonFormField<String?>(
                  value: currentValue.isEmpty ? null : currentValue,
                  decoration: InputDecoration(
                    labelText: 'Type de lien',
                    prefixIcon: const Icon(Iconsax.link),
                    filled: isAdminView,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Aucun lien')),
                    DropdownMenuItem(value: 'product', child: Text('Produit')),
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
                        },
                );
              }),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // Sélection du lien selon le type
              if (controller.selectedLinkType.value.isNotEmpty)
                _buildLinkSelector(context, controller, isAdminView),
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

              // Bouton Modifier (seulement pour Gérant)
              if (!isAdminView)
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
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    BannerController controller,
    bool isMobile,
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
            if (pickedImage != null) {
              return _buildLocalImagePreview(context, pickedImage);
            } else if (controller.imageUrl.value.isNotEmpty) {
              return _buildNetworkImagePreview(
                  context, controller.imageUrl.value);
            } else {
              return _buildImagePlaceholder(context, controller, isMobile);
            }
          }),
          const SizedBox(height: AppSizes.spaceBtwItems),
          if (!isAdminView)
            ElevatedButton.icon(
              onPressed: () => controller.pickImage(isMobile: isMobile),
              icon: const Icon(Iconsax.image),
              label: Text(isMobile
                  ? 'Changer l\'image (Mobile)'
                  : 'Changer l\'image (PC)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocalImagePreview(BuildContext context, XFile imageFile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
      child: FutureBuilder<Uint8List?>(
        future: imageFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            );
          } else if (snapshot.hasError) {
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.error, size: 40),
            );
          } else {
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildNetworkImagePreview(BuildContext context, String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
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
    );
  }

  Widget _buildImagePlaceholder(
    BuildContext context,
    BannerController controller,
    bool isMobile,
  ) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: dark ? TColors.dark : Colors.grey[200],
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.image,
            size: 64,
            color: dark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Text(
            isMobile
                ? 'Taille recommandée: 1200x800px (Mobile)'
                : 'Taille recommandée: 1920x1080px (PC)',
            style: TextStyle(
              color: dark ? Colors.grey[400] : Colors.grey[600],
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

  Widget _buildLinkSelector(
    BuildContext context,
    BannerController controller,
    bool isAdminView,
  ) {
    return Obx(() {
      final linkType = controller.selectedLinkType.value;
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

        return DropdownButtonFormField<String>(
          value: isValidValue ? selectedValue : null,
          decoration: InputDecoration(
            labelText: 'Sélectionner un produit',
            prefixIcon: const Icon(Iconsax.shop),
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
        );
      } else if (linkType == 'establishment') {
        final establishments =
            controller.establishments.where((e) => e.id != null).toList();
        if (establishments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Aucun établissement disponible',
                style: TextStyle(color: Colors.grey)),
          );
        }

        final selectedValue = controller.selectedLinkId.value;
        final isValidValue = selectedValue.isNotEmpty &&
            establishments.any((e) => e.id == selectedValue);

        return DropdownButtonFormField<String>(
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
        );
      }

      return const SizedBox.shrink();
    });
  }
}
