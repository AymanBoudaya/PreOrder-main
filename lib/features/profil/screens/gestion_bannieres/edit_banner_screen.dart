import 'package:caferesto/features/profil/screens/gestion_bannieres/edit_banner_widget/build_action_buttons.dart';
import 'package:caferesto/features/profil/screens/gestion_bannieres/edit_banner_widget/build_changer_statut.dart';
import 'package:caferesto/features/profil/screens/gestion_bannieres/edit_banner_widget/build_type_lien.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../shop/controllers/banner_controller.dart';
import '../../../../data/repositories/product/produit_repository.dart';
import '../../../shop/models/banner_model.dart';
import '../../controllers/liste_etablissement_controller.dart';
import '../../controllers/user_controller.dart';
import 'edit_banner_widget/build_image_section.dart';
import 'edit_banner_widget/name_field.dart';
import 'widgets/link_selector.dart';

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
              BuildImageSection(
                controller: controller,
                isMobile: isMobile,
                banner: banner,
                isAdminView: isAdminView,
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Nom de la bannière
              NameField(
                  controller: controller,
                  isAdminView: isAdminView,
                  banner: banner),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // Type de lien
              BuildTypeLien(
                  controller: controller,
                  isAdminView: isAdminView,
                  banner: banner),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // Sélection du lien selon le type
              if (controller.selectedLinkType.value.isNotEmpty)
                LinkSelector(
                  controller: controller,
                  isAdminView: isAdminView,
                ),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // État actuel - modifiable par l'admin
              BuildChangerStatut(
                  controller: controller,
                  banner: banner,
                  isAdminView: isAdminView),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Boutons d'action
              BuildActionButtons(
                  isAdminView: isAdminView,
                  banner: banner,
                  controller: controller)
            ],
          ),
        ),
      ),
    );
  }
}
