# Proposed MVVM Architecture Structure

## Overview

This document outlines the proposed **MVVM (Model-View-ViewModel)** architecture structure for the PreOrder Flutter application using GetX for state management.

## Architecture Layers

### MVVM Components in Flutter/GetX Context

- **Model**: Pure data classes representing business entities
- **View**: UI screens and widgets (StatelessWidget/StatefulWidget)
- **ViewModel**: GetX Controllers that manage state and business logic
- **Repository**: Data access layer (already exists)
- **Service**: Business logic services (if needed)

## Proposed Directory Structure

```
lib/
├── main.dart                          # Application entry point
├── app.dart                           # App configuration (GetMaterialApp)
├── navigation_menu.dart               # Main navigation menu
│
├── core/                              # Core configuration and utilities
│   ├── constants/                     # Global constants
│   │   ├── api_constants.dart
│   │   ├── colors.dart
│   │   ├── enums.dart
│   │   ├── image_strings.dart
│   │   ├── sizes.dart
│   │   └── text_strings.dart
│   │
│   ├── theme/                         # Application theme
│   │   ├── theme.dart
│   │   └── widget_themes/
│   │       ├── appbar_theme.dart
│   │       ├── bottom_sheet_theme.dart
│   │       ├── checkbox_theme.dart
│   │       ├── chip_theme.dart
│   │       ├── elevated_button_theme.dart
│   │       ├── outlined_button_theme.dart
│   │       ├── text_field_theme.dart
│   │       └── text_theme.dart
│   │
│   ├── utils/                         # General utilities
│   │   ├── device/
│   │   │   └── device_utility.dart
│   │   ├── exceptions/
│   │   │   ├── exceptions.dart
│   │   │   ├── firebase_exceptions.dart
│   │   │   ├── format_exceptions.dart
│   │   │   ├── platform_exceptions.dart
│   │   │   ├── supabase_auth_exceptions.dart
│   │   │   └── supabase_exception.dart
│   │   ├── formatters/
│   │   │   └── formatter.dart
│   │   ├── helpers/
│   │   │   ├── cloud_helper_functions.dart
│   │   │   ├── helper_functions.dart
│   │   │   ├── network_manager.dart
│   │   │   └── pricing_calculator.dart
│   │   ├── http/
│   │   │   └── http_client.dart
│   │   ├── local_storage/
│   │   │   └── storage_utility.dart
│   │   ├── logging/
│   │   │   └── logger.dart
│   │   ├── popups/
│   │   │   ├── full_screen_loader.dart
│   │   │   └── loaders.dart
│   │   ├── validators/
│   │   │   └── validation.dart
│   │   └── animations/
│   │       └── depth_transformer.dart
│   │
│   └── bindings/                      # Global GetX bindings
│       └── general_binding.dart
│
├── data/                              # Data access layer
│   ├── repositories/                  # Data repositories
│   │   ├── address/
│   │   │   └── address_repository.dart
│   │   ├── authentication/
│   │   │   └── authentication_repository.dart
│   │   ├── banner/
│   │   │   └── banner_repository.dart
│   │   ├── categories/
│   │   │   └── category_repository.dart
│   │   ├── etablissement/
│   │   │   └── etablissement_repository.dart
│   │   ├── horaire/
│   │   │   └── horaire_repository.dart
│   │   ├── order/
│   │   │   └── order_repository.dart
│   │   ├── product/
│   │   │   └── produit_repository.dart
│   │   └── user/
│   │       └── user_repository.dart
│   │
│   └── services/                      # Business logic services
│       ├── arrival_time_calculator_service.dart
│       └── (other services as needed)
│
├── features/                          # Feature modules (organized by business domain)
│   │
│   ├── authentication/                # Authentication feature
│   │   ├── models/                    # Data models
│   │   │   └── (auth-specific models if any)
│   │   │
│   │   ├── viewmodels/                # ViewModels (GetX Controllers)
│   │   │   ├── login/
│   │   │   │   └── login_viewmodel.dart
│   │   │   ├── signup/
│   │   │   │   ├── signup_viewmodel.dart
│   │   │   │   └── verify_otp_viewmodel.dart
│   │   │   └── onboarding/
│   │   │       └── onboarding_viewmodel.dart
│   │   │
│   │   ├── views/                     # Views (UI screens)
│   │   │   ├── login/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── login_form.dart
│   │   │   │       └── login_header.dart
│   │   │   ├── signup/
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── signup_form.dart
│   │   │   │       └── verify_email_screen.dart
│   │   │   ├── onboarding/
│   │   │   │   ├── onboarding_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── onboarding_page.dart
│   │   │   └── splash/
│   │   │       └── splash_screen.dart
│   │   │
│   │   └── bindings/                  # Feature-specific bindings
│   │       └── authentication_binding.dart
│   │
│   ├── shop/                          # Shop/E-commerce feature
│   │   ├── models/                    # Data models
│   │   │   ├── product/
│   │   │   │   ├── product_model.dart
│   │   │   │   ├── produit_model.dart
│   │   │   │   ├── product_variation_model.dart
│   │   │   │   ├── product_attribute_model.dart
│   │   │   │   └── taille_prix_model.dart
│   │   │   ├── cart/
│   │   │   │   └── cart_item_model.dart
│   │   │   ├── order/
│   │   │   │   ├── order_model.dart
│   │   │   │   └── payment_method_model.dart
│   │   │   ├── category/
│   │   │   │   ├── category_model.dart
│   │   │   │   └── brand_category_model.dart
│   │   │   ├── brand/
│   │   │   │   └── brand_model.dart
│   │   │   ├── establishment/
│   │   │   │   ├── etablissement_model.dart
│   │   │   │   ├── horaire_model.dart
│   │   │   │   ├── jour_semaine.dart
│   │   │   │   └── statut_etablissement_model.dart
│   │   │   └── banner/
│   │   │       └── banner_model.dart
│   │   │
│   │   ├── viewmodels/                # ViewModels (GetX Controllers)
│   │   │   ├── product/
│   │   │   │   ├── product_viewmodel.dart
│   │   │   │   ├── produit_viewmodel.dart
│   │   │   │   ├── all_products_viewmodel.dart
│   │   │   │   ├── favorites_viewmodel.dart
│   │   │   │   ├── images_viewmodel.dart
│   │   │   │   ├── variation_viewmodel.dart
│   │   │   │   └── share_viewmodel.dart
│   │   │   ├── cart/
│   │   │   │   └── cart_viewmodel.dart
│   │   │   ├── order/
│   │   │   │   ├── order_viewmodel.dart
│   │   │   │   ├── order_list_viewmodel.dart
│   │   │   │   └── checkout_viewmodel.dart
│   │   │   ├── category/
│   │   │   │   └── category_viewmodel.dart
│   │   │   ├── brand/
│   │   │   │   └── brand_viewmodel.dart
│   │   │   ├── establishment/
│   │   │   │   ├── establishment_viewmodel.dart
│   │   │   │   └── horaire_viewmodel.dart
│   │   │   ├── home/
│   │   │   │   ├── home_viewmodel.dart
│   │   │   │   └── banner_viewmodel.dart
│   │   │   ├── search/
│   │   │   │   ├── search_viewmodel.dart
│   │   │   │   └── product_search_viewmodel.dart
│   │   │   ├── navigation/
│   │   │   │   └── navigation_viewmodel.dart
│   │   │   └── dashboard/
│   │   │       └── dashboard_viewmodel.dart
│   │   │
│   │   ├── views/                     # Views (UI screens)
│   │   │   ├── product/
│   │   │   │   ├── product_list_screen.dart
│   │   │   │   ├── product_detail_screen.dart
│   │   │   │   ├── product_reviews_screen.dart
│   │   │   │   ├── add_product_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── product_card.dart
│   │   │   │       ├── product_image_slider.dart
│   │   │   │       ├── product_attributes.dart
│   │   │   │       ├── product_quantity_controls.dart
│   │   │   │       └── product_bottom_bar.dart
│   │   │   ├── cart/
│   │   │   │   ├── cart_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── cart_item_tile.dart
│   │   │   │       ├── cart_bottom_section.dart
│   │   │   │       └── empty_cart_view.dart
│   │   │   ├── order/
│   │   │   │   ├── order_list_screen.dart
│   │   │   │   ├── order_detail_screen.dart
│   │   │   │   ├── order_tracking_screen.dart
│   │   │   │   ├── checkout_screen.dart
│   │   │   │   ├── delivery_map_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── order_card.dart
│   │   │   │       ├── payment_tile.dart
│   │   │   │       └── time_slot_modal.dart
│   │   │   ├── category/
│   │   │   │   ├── category_list_screen.dart
│   │   │   │   ├── category_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── category_card.dart
│   │   │   ├── brand/
│   │   │   │   ├── brand_list_screen.dart
│   │   │   │   ├── brand_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── brand_card.dart
│   │   │   ├── establishment/
│   │   │   │   ├── establishment_list_screen.dart
│   │   │   │   ├── establishment_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── establishment_card.dart
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── home_appbar.dart
│   │   │   │       ├── promo_slider.dart
│   │   │   │       └── search_overlay.dart
│   │   │   ├── favorites/
│   │   │   │   └── favorites_screen.dart
│   │   │   └── search/
│   │   │       └── search_screen.dart
│   │   │
│   │   └── bindings/                  # Feature-specific bindings
│   │       └── shop_binding.dart
│   │
│   ├── personalization/               # Personalization/Profile feature
│   │   ├── models/                    # Data models
│   │   │   ├── user_model.dart
│   │   │   └── address_model.dart
│   │   │
│   │   ├── viewmodels/                # ViewModels (GetX Controllers)
│   │   │   ├── user_viewmodel.dart
│   │   │   ├── address_viewmodel.dart
│   │   │   ├── location_viewmodel.dart
│   │   │   ├── update_name_viewmodel.dart
│   │   │   └── user_management_viewmodel.dart
│   │   │
│   │   ├── views/                     # Views (UI screens)
│   │   │   ├── profile/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── settings/
│   │   │   │   ├── settings_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── address/
│   │   │   │   ├── address_list_screen.dart
│   │   │   │   ├── address_form_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── dashboard/
│   │   │   │   ├── admin_dashboard_screen.dart
│   │   │   │   ├── manager_dashboard_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── dashboard_side_menu.dart
│   │   │   ├── brands/
│   │   │   │   └── (brand management screens)
│   │   │   ├── categories/
│   │   │   │   └── (category management screens)
│   │   │   └── establishments/
│   │   │       └── (establishment management screens)
│   │   │
│   │   └── bindings/                  # Feature-specific bindings
│   │       └── personalization_binding.dart
│   │
│   └── notification/                  # Notification feature
│       ├── models/                    # Data models
│       │   └── notification_model.dart
│       │
│       ├── viewmodels/                # ViewModels (GetX Controllers)
│       │   └── notification_viewmodel.dart
│       │
│       ├── views/                     # Views (UI screens)
│       │   ├── notifications_screen.dart
│       │   └── widgets/
│       │       └── notification_tile.dart
│       │
│       └── bindings/                  # Feature-specific bindings
│           └── notification_binding.dart
│
└── shared/                            # Shared components across features
    ├── widgets/                       # Reusable widgets
    │   ├── appbar/
    │   │   ├── appbar.dart
    │   │   └── tabbar.dart
    │   ├── buttons/
    │   │   └── (reusable buttons)
    │   ├── cards/
    │   │   ├── brand_card.dart
    │   │   ├── category_card.dart
    │   │   └── product_card.dart
    │   ├── images/
    │   │   ├── circular_image.dart
    │   │   └── rounded_image.dart
    │   ├── layouts/
    │   │   └── grid_layout.dart
    │   ├── list_tiles/
    │   │   ├── settings_menu_tile.dart
    │   │   └── user_profile_tile.dart
    │   ├── shimmer/
    │   │   ├── shimmer_effect.dart
    │   │   └── (other shimmer effects)
    │   ├── loaders/
    │   │   ├── animation_loader.dart
    │   │   └── circular_loader.dart
    │   └── success_screen/
    │       └── success_screen.dart
    │
    └── styles/                        # Shared styles
        ├── shadows.dart
        └── spacing_styles.dart
```

## MVVM Architecture Principles

### 1. **Model Layer**
- **Purpose**: Pure data classes representing business entities
- **Responsibilities**:
  - Define data structure
  - Provide serialization/deserialization methods
  - No business logic
  - No UI dependencies

**Example:**
```dart
// lib/features/shop/models/product/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final double price;
  // ... other fields

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
  });

  // Factory constructor for JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // ...
  }

  Map<String, dynamic> toJson() {
    // ...
  }
}
```

### 2. **View Layer**
- **Purpose**: UI components (screens and widgets)
- **Responsibilities**:
  - Display data from ViewModel
  - Handle user interactions
  - No business logic
  - Minimal state (only UI state like form controllers)

**Example:**
```dart
// lib/features/shop/views/product/product_list_screen.dart
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<ProductViewModel>();
    
    return Obx(() => ListView.builder(
      itemCount: viewModel.products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: viewModel.products[index]);
      },
    ));
  }
}
```

### 3. **ViewModel Layer**
- **Purpose**: Manage state and business logic
- **Responsibilities**:
  - Hold observable state (Rx variables)
  - Handle business logic
  - Communicate with repositories
  - Transform data for views
  - Handle user actions

**Example:**
```dart
// lib/features/shop/viewmodels/product/product_viewmodel.dart
class ProductViewModel extends GetxController {
  final ProduitRepository _repository = Get.find();
  
  // Observable state
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxString('');
  
  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }
  
  // Business logic methods
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      final result = await _repository.getProducts();
      products.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  void addToCart(ProductModel product) {
    // Business logic for adding to cart
  }
}
```

### 4. **Repository Layer**
- **Purpose**: Abstract data access
- **Responsibilities**:
  - Fetch data from API/database
  - Cache data if needed
  - Handle data transformation
  - No business logic

### 5. **Service Layer** (Optional)
- **Purpose**: Business logic services
- **Responsibilities**:
  - Complex business calculations
  - Cross-feature business logic
  - Utility services

## Key Differences: MVC vs MVVM

| Aspect | MVC | MVVM |
|--------|-----|------|
| **Controller/ViewModel** | Handles both UI logic and business logic | Separates UI state from business logic |
| **View** | Can directly access Model | Only communicates with ViewModel |
| **Data Binding** | Manual updates | Reactive (automatic with GetX) |
| **Testability** | Harder to test | Easier to test (ViewModel is independent) |
| **Separation** | Less strict | Strict separation of concerns |

## Benefits of MVVM Architecture

1. **Separation of Concerns**: Clear boundaries between layers
2. **Testability**: ViewModels can be tested independently
3. **Maintainability**: Easy to locate and modify code
4. **Scalability**: Easy to add new features
5. **Reusability**: ViewModels can be reused across different views
6. **Reactive Programming**: GetX provides automatic UI updates
7. **Team Collaboration**: Clear structure for team members

## Naming Conventions

- **Models**: `*_model.dart` (e.g., `product_model.dart`)
- **ViewModels**: `*_viewmodel.dart` (e.g., `product_viewmodel.dart`)
- **Views**: `*_screen.dart` or `*_widget.dart` (e.g., `product_list_screen.dart`)
- **Repositories**: `*_repository.dart` (e.g., `product_repository.dart`)
- **Services**: `*_service.dart` (e.g., `arrival_time_calculator_service.dart`)
- **Bindings**: `*_binding.dart` (e.g., `shop_binding.dart`)

## File Organization Rules

1. **One ViewModel per View**: Each screen should have its own ViewModel
2. **Feature-based Organization**: All related files (models, viewmodels, views) in the same feature folder
3. **Shared Components**: Common widgets go in `shared/widgets/`
4. **Core Utilities**: Global utilities go in `core/utils/`
5. **Bindings**: Feature-specific bindings in each feature's `bindings/` folder

## Migration Strategy

See `MIGRATION_GUIDE_MVVM.md` for detailed migration steps.

## Best Practices

1. **ViewModel Naming**: Use `*_viewmodel.dart` instead of `*_controller.dart` to reflect MVVM pattern
2. **State Management**: Use GetX observables (`Rx`, `RxList`, `RxString`, etc.)
3. **Error Handling**: Handle errors in ViewModels, not in Views
4. **Loading States**: Manage loading states in ViewModels
5. **Dependency Injection**: Use GetX bindings for dependency injection
6. **Reactive Updates**: Use `Obx()` or `GetBuilder()` for reactive UI updates
7. **Lifecycle Management**: Override `onInit()`, `onReady()`, `onClose()` in ViewModels

