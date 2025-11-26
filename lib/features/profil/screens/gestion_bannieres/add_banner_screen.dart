import 'dart:typed_data';
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
import '../../../shop/models/etablissement_model.dart';
import '../../controllers/liste_etablissement_controller.dart';
import '../../controllers/user_controller.dart';
import 'widgets/image_preview.dart';

class AddBannerScreen extends StatelessWidget {
  const AddBannerScreen({super.key});

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
          final gerantEtablissement = await etablissementController.getEtablissementUtilisateurConnecte();
          if (gerantEtablissement != null) {
            bannerController.establishments.assignAll([gerantEtablissement]);
          }
        } else {
          // Pour admin, charger tous les établissements
          final establishments = await etablissementController.getTousEtablissements();
          bannerController.establishments.assignAll(establishments);
        }
      } catch (e) {
        debugPrint('Erreur chargement établissements: $e');
      }
    });

    bannerController.clearForm();

    return Scaffold(
      appBar: TAppBar(
        title: const Text("Ajouter une bannière"),
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
                decoration: const InputDecoration(
                  labelText: 'Nom de la bannière',
                  prefixIcon: Icon(Iconsax.text),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // Type de lien
              Obx(() {
                final currentValue = controller.selectedLinkType.value;
                final userController = Get.find<UserController>();
                final isGerant = userController.userRole == 'Gérant';
                
                return DropdownButtonFormField<String?>(
                  initialValue: currentValue.isEmpty ? null : currentValue,
                  decoration: const InputDecoration(
                    labelText: 'Type de lien',
                    prefixIcon: Icon(Iconsax.link),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Aucun lien')),
                    DropdownMenuItem(value: 'product', child: Text('Produit')),
                    DropdownMenuItem(
                      value: 'establishment',
                      child: Text('Établissement'),
                    ),
                  ],
                  onChanged: (value) {
                    controller.selectedLinkType.value = value ?? '';
                    controller.selectedLinkId.value = ''; // Reset selection
                    // Si gérant sélectionne "établissement", définir automatiquement son établissement
                    if (isGerant && value == 'establishment' && controller.establishments.isNotEmpty) {
                      final gerantEtablissement = controller.establishments.firstWhereOrNull((e) => e.id != null);
                      if (gerantEtablissement != null) {
                        controller.selectedLinkId.value = gerantEtablissement.id ?? '';
                      }
                    }
                  },
                );
              }),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // Sélection du lien selon le type
              if (controller.selectedLinkType.value.isNotEmpty)
                _buildLinkSelector(context, controller),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // État actuel (toujours en_attente pour les nouvelles bannières)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'État actuel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Les nouvelles bannières sont créées avec le statut "En attente". L\'administrateur pourra les publier ou les refuser.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Bouton Ajouter
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.addBanner(),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ajouter la bannière'),
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
              return ImagePreview(
                  imageUrl : controller.imageUrl.value);
            } else {
              return _buildImagePlaceholder(context, controller, isMobile);
            }
          }),
          const SizedBox(height: AppSizes.spaceBtwItems),
          ElevatedButton.icon(
            onPressed: () => controller.pickImage(isMobile: isMobile),
            icon: const Icon(Iconsax.image),
            label: Text(isMobile
                ? 'Sélectionner une image (Mobile)'
                : 'Sélectionner une image'),
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

  Widget _buildLinkSelector(
    BuildContext context,
    BannerController controller,
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
          initialValue: isValidValue ? selectedValue : null,
          decoration: const InputDecoration(
            labelText: 'Sélectionner un produit',
            prefixIcon: Icon(Iconsax.shop),
          ),
          items: products.map((product) {
            return DropdownMenuItem(
              value: product.id,
              child: Text(product.name),
            );
          }).toList(),
          onChanged: (value) {
            controller.selectedLinkId.value = value ?? '';
          },
          validator: (value) {
            if (linkType.isNotEmpty && (value == null || value.isEmpty)) {
              return 'Veuillez sélectionner un produit';
            }
            return null;
          },
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
          if (controller.selectedLinkId.value.isEmpty) {
            controller.selectedLinkId.value = gerantEtablissement.id ?? '';
          }
        }

        final selectedValue = controller.selectedLinkId.value;
        final isValidValue = selectedValue.isNotEmpty &&
            establishments.any((e) => e.id == selectedValue);

        // Déterminer l'établissement actuel à afficher
        final currentEstablishment = isValidValue
            ? establishments.firstWhere((e) => e.id == selectedValue)
            : gerantEtablissement;

        // Ne pas afficher le dropdown pour le gérant, afficher directement l'établissement
        if (isGerant && currentEstablishment != null) {
          return Container(
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
          );
        }

        // Pour l'admin, afficher le dropdown
        return DropdownButtonFormField<String>(
          initialValue: isValidValue ? selectedValue : null,
          decoration: const InputDecoration(
            labelText: 'Sélectionner un établissement',
            prefixIcon: Icon(Iconsax.home),
          ),
          items: establishments.map((establishment) {
            return DropdownMenuItem(
              value: establishment.id!,
              child: Text(establishment.name),
            );
          }).toList(),
          onChanged: (value) {
            controller.selectedLinkId.value = value ?? '';
          },
          validator: (value) {
            if (linkType.isNotEmpty && (value == null || value.isEmpty)) {
              return 'Veuillez sélectionner un établissement';
            }
            return null;
          },
        );
      }

      return const SizedBox.shrink();
    });
  }
}
