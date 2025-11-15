import 'package:caferesto/features/authentication/screens/signup.widgets/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/controllers/user_controller.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();
  final userController = Get.find<UserController>();

  /// Variables
  final rememberMe = false.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    print("🟡 [LoginController] onInit() CALLED");

    email.text = localStorage.read("REMEMBER_ME_EMAIL") ?? '';
    password.text = localStorage.read("REMEMBER_ME_PASSWORD") ?? '';
    super.onInit();
  }

  void emailOtpSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "Envoi du code OTP...",
        TImages.docerAnimation,
      );

      // Vérifier connexion internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Valider formulaire
      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Sauvegarder email si "Remember Me"
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
      }

      // Envoi OTP via AuthenticationRepository
      await AuthenticationRepository.instance.sendOtp(email.text.trim());

      TFullScreenLoader.stopLoading();

      // Aller vers l'écran OTP
      Get.to(() => OTPVerificationScreen(
            email: email.text.trim(),
            userData: {},
            isSignupFlow: false,
          ));
      TLoaders.successSnackBar(
          title: 'OTP envoyé !', message: 'Vérifier votre boîte e-mail');
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Erreur !', message: e.toString());
    }
  }
}
