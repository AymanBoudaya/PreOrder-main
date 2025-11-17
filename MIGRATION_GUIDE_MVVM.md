# MVVM Migration Guide

## Overview

This guide will help you migrate your current codebase to the proposed MVVM (Model-View-ViewModel) architecture structure. The migration should be done progressively, feature by feature, to minimize risks.

## Prerequisites

- [ ] Create a Git branch: `git checkout -b refactor/mvvm-structure`
- [ ] Make a complete backup of your project
- [ ] Document current dependencies between modules
- [ ] Ensure all tests pass before starting

## Migration Phases

### Phase 1: Preparation and Core Setup

#### Step 1.1: Create New Directory Structure

```bash
# Create core directories
mkdir -p lib/core/{constants,theme,utils,bindings}
mkdir -p lib/data/{repositories,services}
mkdir -p lib/shared/{widgets,styles}

# Create feature directories with MVVM structure
mkdir -p lib/features/authentication/{models,viewmodels,views,bindings}
mkdir -p lib/features/shop/{models,viewmodels,views,bindings}
mkdir -p lib/features/personalization/{models,viewmodels,views,bindings}
mkdir -p lib/features/notification/{models,viewmodels,views,bindings}
```

#### Step 1.2: Move Core Files

```bash
# Move constants
mv lib/utils/constants/* lib/core/constants/

# Move theme
mv lib/utils/theme/* lib/core/theme/

# Move utilities (except constants and theme)
mv lib/utils/device lib/core/utils/
mv lib/utils/exceptions lib/core/utils/
mv lib/utils/formatters lib/core/utils/
mv lib/utils/helpers lib/core/utils/
mv lib/utils/http lib/core/utils/
mv lib/utils/local_storage lib/core/utils/
mv lib/utils/logging lib/core/utils/
mv lib/utils/popups lib/core/utils/
mv lib/utils/validators lib/core/utils/
```

#### Step 1.3: Move Shared Components

```bash
# Move shared widgets
mv lib/common/widgets/* lib/shared/widgets/

# Move shared styles
mv lib/common/styles/* lib/shared/styles/
```

### Phase 2: Update Core Imports

#### Step 2.1: Update Import Paths

Search and replace in all files:

```bash
# Core imports
'package:caferesto/utils/constants/' → 'package:caferesto/core/constants/'
'package:caferesto/utils/theme/' → 'package:caferesto/core/theme/'
'package:caferesto/utils/' → 'package:caferesto/core/utils/'

# Shared imports
'package:caferesto/common/widgets/' → 'package:caferesto/shared/widgets/'
'package:caferesto/common/styles/' → 'package:caferesto/shared/styles/'
```

**PowerShell Script for Windows:**
```powershell
# Update core imports
Get-ChildItem -Path lib -Recurse -Filter *.dart | ForEach-Object {
    (Get-Content $_.FullName) -replace "package:caferesto/utils/constants/", "package:caferesto/core/constants/" | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace "package:caferesto/utils/theme/", "package:caferesto/core/theme/" | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace "package:caferesto/utils/", "package:caferesto/core/utils/" | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace "package:caferesto/common/widgets/", "package:caferesto/shared/widgets/" | Set-Content $_.FullName
    (Get-Content $_.FullName) -replace "package:caferesto/common/styles/", "package:caferesto/shared/styles/" | Set-Content $_.FullName
}
```

### Phase 3: Migrate Authentication Feature

#### Step 3.1: Organize Authentication Models

```bash
# Create model directories if needed
mkdir -p lib/features/authentication/models

# Move models (if any exist)
# Currently, authentication might not have separate models
```

#### Step 3.2: Rename Controllers to ViewModels

```bash
# Rename controllers to viewmodels
cd lib/features/authentication/controllers

# Rename files
mv login/login_controller.dart ../viewmodels/login/login_viewmodel.dart
mv signup/signup_controller.dart ../viewmodels/signup/signup_viewmodel.dart
mv signup/verify_otp_controller.dart ../viewmodels/signup/verify_otp_viewmodel.dart
mv onboarding/onboarding_controller.dart ../viewmodels/onboarding/onboarding_viewmodel.dart
```

#### Step 3.3: Update Controller Classes to ViewModel

For each ViewModel file, update the class name:

**Before:**
```dart
class LoginController extends GetxController {
  // ...
}
```

**After:**
```dart
class LoginViewModel extends GetxController {
  // ...
}
```

#### Step 3.4: Move Views

```bash
# Move screens to views
mv lib/features/authentication/screens/* lib/features/authentication/views/
```

#### Step 3.5: Update View Imports

In all view files, update imports:

```dart
// Before
import 'package:caferesto/features/authentication/controllers/login/login_controller.dart';
final controller = Get.find<LoginController>();

// After
import 'package:caferesto/features/authentication/viewmodels/login/login_viewmodel.dart';
final viewModel = Get.find<LoginViewModel>();
```

#### Step 3.6: Create Authentication Binding

Create `lib/features/authentication/bindings/authentication_binding.dart`:

```dart
import 'package:get/get.dart';
import '../viewmodels/login/login_viewmodel.dart';
import '../viewmodels/signup/signup_viewmodel.dart';
import '../viewmodels/signup/verify_otp_viewmodel.dart';
import '../viewmodels/onboarding/onboarding_viewmodel.dart';

class AuthenticationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginViewModel());
    Get.lazyPut(() => SignupViewModel());
    Get.lazyPut(() => VerifyOtpViewModel());
    Get.lazyPut(() => OnboardingViewModel());
  }
}
```

### Phase 4: Migrate Shop Feature

#### Step 4.1: Organize Shop Models

```bash
# Create model subdirectories
mkdir -p lib/features/shop/models/{product,cart,order,category,brand,establishment,banner}

# Move models to appropriate subdirectories
mv lib/features/shop/models/product_model.dart lib/features/shop/models/product/
mv lib/features/shop/models/produit_model.dart lib/features/shop/models/product/
mv lib/features/shop/models/product_variation_model.dart lib/features/shop/models/product/
mv lib/features/shop/models/product_attribute_model.dart lib/features/shop/models/product/
mv lib/features/shop/models/taille_prix_model.dart lib/features/shop/models/product/
mv lib/features/shop/models/cart_item_model.dart lib/features/shop/models/cart/
mv lib/features/shop/models/order_model.dart lib/features/shop/models/order/
mv lib/features/shop/models/payment_method_model.dart lib/features/shop/models/order/
# ... continue for other models
```

#### Step 4.2: Rename Controllers to ViewModels

```bash
# Create viewmodel directories
mkdir -p lib/features/shop/viewmodels/{product,cart,order,category,brand,establishment,home,search,navigation,dashboard}

# Rename and move controllers
mv lib/features/shop/controllers/product/produit_controller.dart lib/features/shop/viewmodels/product/produit_viewmodel.dart
mv lib/features/shop/controllers/product/all_products_controller.dart lib/features/shop/viewmodels/product/all_products_viewmodel.dart
mv lib/features/shop/controllers/product/favorites_controller.dart lib/features/shop/viewmodels/product/favorites_viewmodel.dart
mv lib/features/shop/controllers/product/images_controller.dart lib/features/shop/viewmodels/product/images_viewmodel.dart
mv lib/features/shop/controllers/product/variation_controller.dart lib/features/shop/viewmodels/product/variation_viewmodel.dart
mv lib/features/shop/controllers/product/panier_controller.dart lib/features/shop/viewmodels/cart/cart_viewmodel.dart
mv lib/features/shop/controllers/product/order_controller.dart lib/features/shop/viewmodels/order/order_viewmodel.dart
mv lib/features/shop/controllers/product/checkout_controller.dart lib/features/shop/viewmodels/order/checkout_viewmodel.dart
mv lib/features/shop/controllers/commandes/order_list_controller.dart lib/features/shop/viewmodels/order/order_list_viewmodel.dart
mv lib/features/shop/controllers/category_controller.dart lib/features/shop/viewmodels/category/category_viewmodel.dart
mv lib/features/shop/controllers/banner_controller.dart lib/features/shop/viewmodels/home/banner_viewmodel.dart
mv lib/features/shop/controllers/home_controller.dart lib/features/shop/viewmodels/home/home_viewmodel.dart
mv lib/features/shop/controllers/search_controller.dart lib/features/shop/viewmodels/search/search_viewmodel.dart
mv lib/features/shop/controllers/product/product_serach_controller.dart lib/features/shop/viewmodels/search/product_search_viewmodel.dart
mv lib/features/shop/controllers/navigation_controller.dart lib/features/shop/viewmodels/navigation/navigation_viewmodel.dart
mv lib/features/shop/controllers/etablissement_controller.dart lib/features/shop/viewmodels/establishment/establishment_viewmodel.dart
mv lib/features/shop/controllers/dashboard_controller.dart lib/features/shop/viewmodels/dashboard/dashboard_viewmodel.dart
mv lib/features/shop/controllers/product/horaire_controller.dart lib/features/shop/viewmodels/establishment/horaire_viewmodel.dart
```

#### Step 4.3: Update ViewModel Class Names

For each ViewModel file, update:
1. Class name from `*Controller` to `*ViewModel`
2. File comments/documentation
3. Static getter names (if any)

**Example:**
```dart
// Before
class ProduitController extends GetxController {
  static ProduitController get instance => Get.find();
  // ...
}

// After
class ProduitViewModel extends GetxController {
  static ProduitViewModel get instance => Get.find();
  // ...
}
```

#### Step 4.4: Move Views

```bash
# Create view subdirectories
mkdir -p lib/features/shop/views/{product,cart,order,category,brand,establishment,home,favorites,search}

# Move screens to views
mv lib/features/shop/screens/product_details/* lib/features/shop/views/product/
mv lib/features/shop/screens/product_reviews/* lib/features/shop/views/product/
mv lib/features/shop/screens/all_products/* lib/features/shop/views/product/
mv lib/features/shop/screens/cart/* lib/features/shop/views/cart/
mv lib/features/shop/screens/checkout/* lib/features/shop/views/order/
mv lib/features/shop/screens/order/* lib/features/shop/views/order/
mv lib/features/shop/screens/categories/* lib/features/shop/views/category/
mv lib/features/shop/screens/brand/* lib/features/shop/views/brand/
mv lib/features/shop/screens/store/* lib/features/shop/views/establishment/
mv lib/features/shop/screens/home/* lib/features/shop/views/home/
mv lib/features/shop/screens/favorite/* lib/features/shop/views/favorites/
# ... continue for other screens
```

#### Step 4.5: Update View Imports

Update all view files to use ViewModels instead of Controllers:

```dart
// Before
import 'package:caferesto/features/shop/controllers/product/produit_controller.dart';
final controller = Get.find<ProduitController>();

// After
import 'package:caferesto/features/shop/viewmodels/product/produit_viewmodel.dart';
final viewModel = Get.find<ProduitViewModel>();
```

#### Step 4.6: Create Shop Binding

Create `lib/features/shop/bindings/shop_binding.dart`:

```dart
import 'package:get/get.dart';
import '../viewmodels/product/produit_viewmodel.dart';
import '../viewmodels/cart/cart_viewmodel.dart';
import '../viewmodels/order/order_viewmodel.dart';
// ... other imports

class ShopBinding extends Bindings {
  @override
  void dependencies() {
    // Product ViewModels
    Get.lazyPut(() => ProduitViewModel(), fenix: true);
    Get.lazyPut(() => AllProductsViewModel(), fenix: true);
    Get.lazyPut(() => FavoritesViewModel(), fenix: true);
    
    // Cart ViewModel
    Get.lazyPut(() => CartViewModel(), fenix: true);
    
    // Order ViewModels
    Get.lazyPut(() => OrderViewModel());
    Get.lazyPut(() => CheckoutViewModel(), fenix: true);
    
    // ... other ViewModels
  }
}
```

### Phase 5: Migrate Personalization Feature

#### Step 5.1: Organize Models

```bash
# Models are already in the right place
# Just ensure they're in models/ directory
```

#### Step 5.2: Rename Controllers to ViewModels

```bash
mv lib/features/personalization/controllers/user_controller.dart lib/features/personalization/viewmodels/user_viewmodel.dart
mv lib/features/personalization/controllers/address_controller.dart lib/features/personalization/viewmodels/address_viewmodel.dart
mv lib/features/personalization/controllers/update_name_controller.dart lib/features/personalization/viewmodels/update_name_viewmodel.dart
mv lib/features/personalization/controllers/user_management_controller.dart lib/features/personalization/viewmodels/user_management_viewmodel.dart
```

#### Step 5.3: Move Views

```bash
mv lib/features/personalization/screens/* lib/features/personalization/views/
```

#### Step 5.4: Update Imports and Create Binding

Follow the same pattern as previous features.

### Phase 6: Migrate Notification Feature

#### Step 6.1: Organize Structure

```bash
# Move models
mv lib/features/notification/models/* lib/features/notification/models/

# Rename controller
mv lib/features/notification/controllers/notification_controller.dart lib/features/notification/viewmodels/notification_viewmodel.dart

# Move views
mv lib/features/notification/screens/* lib/features/notification/views/
```

### Phase 7: Update General Binding

Update `lib/core/bindings/general_binding.dart`:

```dart
import 'package:get/get.dart';
import '../../features/shop/bindings/shop_binding.dart';
import '../../features/authentication/bindings/authentication_binding.dart';
import '../../features/personalization/bindings/personalization_binding.dart';
import '../../features/notification/bindings/notification_binding.dart';
import '../../data/repositories/address/address_repository.dart';
// ... other repository imports

class GeneralBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories first
    Get.lazyPut<ProduitRepository>(() => ProduitRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    // ... other repositories
    
    // Initialize feature bindings
    ShopBinding().dependencies();
    AuthenticationBinding().dependencies();
    PersonalizationBinding().dependencies();
    NotificationBinding().dependencies();
  }
}
```

### Phase 8: Update All References

#### Step 8.1: Find and Replace Controller References

Search for all instances of:
- `*Controller` → `*ViewModel`
- `*_controller.dart` → `*_viewmodel.dart`
- `Get.find<*Controller>()` → `Get.find<*ViewModel>()`

**PowerShell Script:**
```powershell
Get-ChildItem -Path lib -Recurse -Filter *.dart | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace 'Controller', 'ViewModel'
    $content = $content -replace '_controller\.dart', '_viewmodel.dart'
    Set-Content -Path $_.FullName -Value $content -NoNewline
}
```

**Note:** Be careful with this script as it might replace too much. Review changes manually.

#### Step 8.2: Update Variable Names

In view files, consider renaming:
- `controller` → `viewModel`
- `_controller` → `_viewModel`

This is optional but improves code clarity.

### Phase 9: Testing and Validation

#### Step 9.1: Run Analysis

```bash
flutter analyze
```

#### Step 9.2: Fix Import Errors

Fix any remaining import errors manually.

#### Step 9.3: Test Each Feature

Test each feature module:
1. Authentication (login, signup, onboarding)
2. Shop (products, cart, orders)
3. Personalization (profile, settings)
4. Notifications

#### Step 9.4: Run Tests

```bash
flutter test
```

### Phase 10: Cleanup

#### Step 10.1: Remove Old Directories

After confirming everything works:

```bash
# Remove old controller directories (if empty)
rmdir lib/features/*/controllers

# Remove old screen directories (if empty)
rmdir lib/features/*/screens

# Remove old utils directory (if empty)
rmdir lib/utils

# Remove old common directory (if empty)
rmdir lib/common
```

#### Step 10.2: Update Documentation

- Update README.md
- Update any architecture documentation
- Update team guidelines

## Migration Checklist

### Before Migration
- [ ] Create Git branch
- [ ] Backup project
- [ ] Document dependencies
- [ ] Run all tests

### Core Migration
- [ ] Move core files (constants, theme, utils)
- [ ] Move shared components
- [ ] Update core imports
- [ ] Test core functionality

### Feature Migration (for each feature)
- [ ] Organize models
- [ ] Rename controllers to viewmodels
- [ ] Update class names
- [ ] Move views
- [ ] Update view imports
- [ ] Create feature binding
- [ ] Test feature

### Final Steps
- [ ] Update general binding
- [ ] Update all references
- [ ] Run flutter analyze
- [ ] Fix all errors
- [ ] Run tests
- [ ] Test app manually
- [ ] Cleanup old directories
- [ ] Update documentation

## Common Issues and Solutions

### Issue 1: Import Errors
**Problem:** Files can't find renamed classes
**Solution:** 
1. Use IDE's "Find and Replace in Files" feature
2. Update imports manually
3. Run `flutter pub get` after changes

### Issue 2: Binding Errors
**Problem:** ViewModels not found at runtime
**Solution:**
1. Check that bindings are registered in feature bindings
2. Ensure feature bindings are called in GeneralBinding
3. Verify ViewModel classes are exported correctly

### Issue 3: Circular Dependencies
**Problem:** Circular imports between features
**Solution:**
1. Move shared models to `shared/models/`
2. Use dependency injection properly
3. Avoid direct imports between features

### Issue 4: Static Getter Issues
**Problem:** `Get.find<*Controller>()` fails
**Solution:**
1. Update static getters to use ViewModel
2. Ensure ViewModels are registered in bindings
3. Use `Get.find<*ViewModel>()` instead

## Best Practices During Migration

1. **Migrate One Feature at a Time**: Don't migrate everything at once
2. **Test After Each Feature**: Ensure each feature works before moving to the next
3. **Commit Frequently**: Make small commits after each successful migration step
4. **Use IDE Refactoring**: Use your IDE's refactoring tools when possible
5. **Review Changes**: Review all changes before committing
6. **Update Tests**: Update unit tests to use ViewModels instead of Controllers

## Rollback Plan

If something goes wrong:

```bash
# Switch back to main branch
git checkout main

# Or reset to a specific commit
git reset --hard <commit-hash>
```

## Post-Migration

After successful migration:

1. **Code Review**: Have team members review the changes
2. **Documentation**: Update architecture documentation
3. **Team Training**: Brief team on new structure
4. **Monitor**: Monitor for any runtime issues
5. **Optimize**: Look for opportunities to optimize the new structure

## Support

If you encounter issues:
1. Check the `PROPOSED_STRUCTURE_MVVM.md` file for structure reference
2. Review GetX documentation for bindings
3. Check Flutter best practices for MVVM
4. Consult with team members

