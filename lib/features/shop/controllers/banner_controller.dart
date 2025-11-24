import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/banner/banner_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/banner_model.dart';
import '../models/etablissement_model.dart';
import '../models/produit_model.dart';
import '../../profil/controllers/user_controller.dart';

class BannerController extends GetxController {

  // Repository
  final _bannerRepository = Get.find<BannerRepository>();
  final _userController = Get.find<UserController>();
  final _db = Supabase.instance.client;

  // Realtime channel
  RealtimeChannel? _bannersChannel;

  // Observable variables
  final RxList<BannerModel> allBanners = <BannerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedTabIndex = 0.obs; // 0: en_attente, 1: publiee, 2: refusee

  // Form variables
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final RxString imageUrl = ''.obs;
  final RxString selectedStatus = 'en_attente'.obs; // 'en_attente', 'publiee', 'refusee'
  final RxString selectedLinkType = ''.obs; // 'product', 'establishment'
  final RxString selectedLinkId = ''.obs;

  // Dropdown options
  final RxList<ProduitModel> products = <ProduitModel>[].obs;
  final RxList<Etablissement> establishments = <Etablissement>[].obs;

  // Selected banner for editing
  final Rx<BannerModel?> selectedBanner = Rx<BannerModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAllBanners();
    _subscribeToRealtimeBanners();
  }

  @override
  void onClose() {
    _unsubscribeFromRealtimeBanners();
    super.onClose();
  }

  /// Fetch all banners
  Future<void> fetchAllBanners() async {
    try {
      isLoading.value = true;
      final banners = await _bannerRepository.getAllBanners();
      allBanners.assignAll(banners);
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur lors du chargement des bannières: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get published banners from cache (allBanners) - Ne recharge pas depuis la DB
  List<BannerModel> getPublishedBanners() {
    return getBannersByStatus('publiee');
  }

  /// Load published banners from DB (only if needed)
  Future<void> loadPublishedBannersIfNeeded() async {
    // Si allBanners est vide, charger toutes les bannières
    if (allBanners.isEmpty && !isLoading.value) {
      await fetchAllBanners();
    }
  }

  /// Get banners by status
  List<BannerModel> getBannersByStatus(String status) {
    return allBanners.where((banner) => banner.status == status).toList();
  }

  /// Get filtered banners based on selected tab
  List<BannerModel> getFilteredBannersByTab() {
    final statuses = ['en_attente', 'publiee', 'refusee'];
    if (selectedTabIndex.value >= 0 && selectedTabIndex.value < statuses.length) {
      final status = statuses[selectedTabIndex.value];
      return getFilteredBanners().where((banner) => banner.status == status).toList();
    }
    return [];
  }

  /// Check if user is Admin
  bool get isAdmin => _userController.userRole == 'Admin';

  /// Check if user is Gerant
  bool get isGerant => _userController.userRole == 'Gérant';

  /// Check if user can add/edit/delete banners
  bool get canManageBanners => isGerant;

  /// Check if user can change banner status
  bool get canChangeStatus => isAdmin;

  /// Pick image from gallery or camera
  Future<void> pickImage({bool isMobile = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: isMobile ? 85 : 90,
        maxWidth: isMobile ? 1200 : 1920,
        maxHeight: isMobile ? 800 : 1080,
      );

      if (image != null) {
        pickedImage.value = image;
        imageUrl.value = ''; // Reset URL when new image is picked
      }
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur lors de la sélection de l\'image: $e');
    }
  }

  /// Add banner
  Future<void> addBanner() async {
    try {
      // Validation
      if (!formKey.currentState!.validate()) {
        return;
      }

      if (pickedImage.value == null && imageUrl.value.isEmpty) {
        TLoaders.warningSnackBar(
          title: 'Image manquante',
          message: 'Veuillez sélectionner une image pour la bannière',
        );
        return;
      }

      isLoading.value = true;

      // Upload image if a new one was picked
      String finalImageUrl = imageUrl.value;
      if (pickedImage.value != null) {
        final screenWidth = Get.width;
        final isMobileSize = screenWidth < 768;
        finalImageUrl = await _bannerRepository.uploadBannerImage(
          pickedImage.value!,
          isMobile: isMobileSize,
        );
      }

      // Create banner (Gérant only, status always 'en_attente' for new banners)
      if (!canManageBanners) {
        TLoaders.errorSnackBar(
          title: 'Permission refusée',
          message: 'Seuls les gérants peuvent ajouter des bannières',
        );
        return;
      }

      final banner = BannerModel(
        id: '',
        name: nameController.text.trim(),
        imageUrl: finalImageUrl,
        status: 'en_attente', // Nouvelle bannière toujours en attente
        link: selectedLinkId.value.isNotEmpty ? selectedLinkId.value : null,
        linkType: selectedLinkType.value.isNotEmpty ? selectedLinkType.value : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final newBanner = await _bannerRepository.addBanner(banner);
      await fetchAllBanners();
      
      // Envoyer une notification aux admins
      await _notifyAdminsNewBanner(newBanner);
      
      clearForm();
      Get.back(); // Fermer l'écran
      TLoaders.successSnackBar(
        title: 'Succès',
        message: 'Bannière ajoutée avec succès',
      );
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur lors de l\'ajout de la bannière: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update banner
  Future<void> updateBanner(String bannerId) async {
    try {
      // Check permissions
      if (!canManageBanners) {
        TLoaders.errorSnackBar(
          title: 'Permission refusée',
          message: 'Seuls les gérants peuvent modifier des bannières',
        );
        return;
      }

      // Validation
      if (!formKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true;

      // Get existing banner to preserve status
      final existingBanner = allBanners.firstWhere((b) => b.id == bannerId);

      // Upload new image if one was picked
      String finalImageUrl = imageUrl.value;
      if (pickedImage.value != null) {
        final screenWidth = Get.width;
        final isMobileSize = screenWidth < 768;
        finalImageUrl = await _bannerRepository.uploadBannerImage(
          pickedImage.value!,
          isMobile: isMobileSize,
        );
      }

      // Update banner (Gérant cannot change status, only Admin can)
      final banner = BannerModel(
        id: bannerId,
        name: nameController.text.trim(),
        imageUrl: finalImageUrl,
        status: existingBanner.status, // Preserve existing status
        link: selectedLinkId.value.isNotEmpty ? selectedLinkId.value : null,
        linkType: selectedLinkType.value.isNotEmpty ? selectedLinkType.value : null,
        createdAt: existingBanner.createdAt,
        updatedAt: DateTime.now(),
      );

      await _bannerRepository.updateBanner(banner);
      await fetchAllBanners();
      
      clearForm();
      Get.back(); // Fermer l'écran
      TLoaders.successSnackBar(
        title: 'Succès',
        message: 'Bannière mise à jour avec succès',
      );
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur lors de la mise à jour de la bannière: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete banner
  Future<void> deleteBanner(String bannerId) async {
    try {
      // Check permissions
      if (!canManageBanners) {
        TLoaders.errorSnackBar(
          title: 'Permission refusée',
          message: 'Seuls les gérants peuvent supprimer des bannières',
        );
        return;
      }

      // Get banner to delete image
      final banner = allBanners.firstWhere((b) => b.id == bannerId);
      
      isLoading.value = true;
      
      // Delete image from storage
      if (banner.imageUrl.isNotEmpty) {
        await _bannerRepository.deleteBannerImage(banner.imageUrl);
      }
      
      // Delete banner
      await _bannerRepository.deleteBanner(bannerId);
      await fetchAllBanners();
      
      // Afficher le snackbar de succès
      TLoaders.successSnackBar(
        title: 'Succès',
        message: 'Bannière supprimée avec succès',
      );
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur lors de la suppression de la bannière: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update banner status (Admin only)
  Future<void> updateBannerStatus(String bannerId, String newStatus) async {
    try {
      if (!canChangeStatus) {
        TLoaders.errorSnackBar(
          title: 'Permission refusée',
          message: 'Seuls les administrateurs peuvent changer le statut des bannières',
        );
        return;
      }

      if (!['en_attente', 'publiee', 'refusee'].contains(newStatus)) {
        TLoaders.errorSnackBar(
          title: 'Erreur',
          message: 'Statut invalide',
        );
        return;
      }

      isLoading.value = true;
      await _bannerRepository.updateBannerStatus(bannerId, newStatus);
      await fetchAllBanners();
      
      TLoaders.successSnackBar(
        title: 'Succès',
        message: 'Statut de la bannière mis à jour',
      );
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur lors de la mise à jour du statut: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load banner for editing
  void loadBannerForEditing(BannerModel banner) {
    selectedBanner.value = banner;
    nameController.text = banner.name;
    imageUrl.value = banner.imageUrl;
    pickedImage.value = null;
    selectedStatus.value = banner.status;
    selectedLinkType.value = banner.linkType ?? '';
    selectedLinkId.value = banner.link ?? '';
  }

  /// Clear form
  void clearForm() {
    nameController.clear();
    pickedImage.value = null;
    imageUrl.value = '';
    selectedStatus.value = 'en_attente';
    selectedLinkType.value = '';
    selectedLinkId.value = '';
    selectedBanner.value = null;
  }

  /// Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// Get filtered banners
  List<BannerModel> getFilteredBanners() {
    if (searchQuery.value.isEmpty) {
      return allBanners.toList();
    }
    return allBanners
        .where((banner) =>
            banner.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  /// Refresh banners
  Future<void> refreshBanners() async {
    await fetchAllBanners();
  }

  /// S'abonner aux changements en temps réel des bannières
  void _subscribeToRealtimeBanners() {
    try {
      _bannersChannel = _db.channel('banners_realtime');
      
      _bannersChannel!.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'banners',
        callback: (payload) {
          try {
            final eventType = payload.eventType;
            final newData = payload.newRecord;
            final oldData = payload.oldRecord;

            if (eventType == PostgresChangeEvent.insert) {
              final banner = BannerModel.fromJson(newData);
              // Vérifier si la bannière n'existe pas déjà dans la liste
              final index = allBanners.indexWhere((b) => b.id == banner.id);
              if (index == -1) {
                allBanners.insert(0, banner);
                allBanners.refresh();
              }
            } else if (eventType == PostgresChangeEvent.update) {
              final banner = BannerModel.fromJson(newData);
              final index = allBanners.indexWhere((b) => b.id == banner.id);
              if (index != -1) {
                allBanners[index] = banner;
                allBanners.refresh();
              } else {
                // Si la bannière n'existe pas, l'ajouter
                allBanners.insert(0, banner);
                allBanners.refresh();
              }
            } else if (eventType == PostgresChangeEvent.delete) {
              final id = oldData['id']?.toString();
              if (id != null) {
                allBanners.removeWhere((b) => b.id == id);
                allBanners.refresh();
              }
            }
          } catch (e) {
            debugPrint('Erreur traitement changement bannière temps réel: $e');
          }
        },
      );

      _bannersChannel!.subscribe(
        (status, [_]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            debugPrint('Abonnement temps réel activé pour les bannières');
          } else if (status == RealtimeSubscribeStatus.channelError) {
            debugPrint('Erreur abonnement temps réel bannières');
          }
        },
      );
    } catch (e) {
      debugPrint('Erreur abonnement temps réel bannières: $e');
    }
  }

  /// Se désabonner des changements en temps réel
  void _unsubscribeFromRealtimeBanners() {
    if (_bannersChannel != null) {
      try {
        _db.removeChannel(_bannersChannel!);
        _bannersChannel = null;
        debugPrint('Désabonné de l\'écoute temps réel des bannières');
      } catch (e) {
        debugPrint('Erreur lors de la désinscription temps réel: $e');
      }
    }
  }

  /// Notifier les admins lorsqu'une nouvelle bannière est ajoutée
  Future<void> _notifyAdminsNewBanner(BannerModel banner) async {
    try {
      // Récupérer le nom du gérant
      final gerantName = _userController.user.value.fullName.isNotEmpty
          ? _userController.user.value.fullName
          : 'Un gérant';

      // Récupérer tous les admins
      final adminUsers = await _db
          .from('users')
          .select('id')
          .eq('role', 'Admin');

      if (adminUsers.isEmpty) {
        debugPrint('⚠️ Aucun admin trouvé pour notifier');
        return;
      }

      // Envoyer une notification à chaque admin
      for (final admin in adminUsers) {
        try {
          await _db.from('notifications').insert({
            'user_id': admin['id'],
            'title': 'Nouvelle bannière à valider',
            'message': '$gerantName a ajouté une nouvelle bannière "${banner.name}".',
            'read': false,
            'created_at': DateTime.now().toIso8601String(),
          });
          debugPrint('Notification créée pour admin ${admin['id']}');
        } catch (e) {
          debugPrint('Erreur création notification pour admin ${admin['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur envoi notification aux admins: $e');
      // Ne pas faire échouer l'ajout de la bannière si la notification échoue
    }
  }
}

