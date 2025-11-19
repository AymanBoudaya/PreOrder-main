import 'package:get/get.dart';

class VariationController extends GetxController {
  /// Variables
  final RxMap<String, dynamic> selectedAttributes = <String, dynamic>{}.obs;
  final RxString variationStockStatus = ''.obs;
  // Use Map<String, String>? to match CartItemModel.selectedVariation
  final Rx<Map<String, String>?> selectedVariation =
      Rx<Map<String, String>?>(null);

  /// -- Check if selected attributes match variation attributes
  RxString selectedSize = ''.obs;
  RxDouble selectedPrice = 0.0.obs;

  void selectVariation(String size, double price) {
    selectedSize.value = size;
    selectedPrice.value = price;

    // Use size as the variation ID (as it matches cart item variationId)
    // This ensures consistency between cart items and product variations
    final variationId = size;

    // Create or update the variation map (matching CartItemModel structure)
    selectedVariation.value = {
      'id': variationId,
      'taille': size,
      'prix': price.toString(),
    };
  }

  void clearVariation() {
    selectedSize.value = '';
    selectedPrice.value = 0.0;
    selectedVariation.value = null;
  }

  @override
  void onClose() {
    // Nettoyage automatique quand le contrôleur est supprimé
    clearVariation();
    super.onClose();
  }

  /// -- Reset all selections
  void resetSelectedAttributes() {
    selectedAttributes.clear();
    variationStockStatus.value = '';
    selectedVariation.value = null;
    // Also clear selectedSize and selectedPrice to keep UI in sync
    clearVariation();
  }
}
