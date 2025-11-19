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
  final email = TextEditingController();
  final rememberMe = false.obs;
  final localStorage = GetStorage();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    email.text = localStorage.read("REMEMBER_ME_EMAIL") ?? '';
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
      final otpSent =
          await AuthenticationRepository.instance.sendOtp(email.text.trim());

      TFullScreenLoader.stopLoading();

      if (!otpSent) {
        return;
      }
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
      final errorMessage = e.toString();
      if (errorMessage.contains("you can only request this")) {
        TLoaders.errorSnackBar(
          title: "Trop de demandes",
          message: "Attendez avant de demander un nouveau code OTP.",
        );
      } else if (errorMessage.contains("otp_disabled") ||
          errorMessage.contains("signups not allowed")) {
        TLoaders.errorSnackBar(
          title: "Email inconnu",
          message: "Aucun utilisateur n'est associé à cet email.",
        );
      } else {
        TLoaders.errorSnackBar(
          title: 'Erreur Login !',
          message: errorMessage,
        );
      }
    }
  }
}
