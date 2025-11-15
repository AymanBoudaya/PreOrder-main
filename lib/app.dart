import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bindings/general_binding.dart';
import 'features/authentication/screens/login/login.dart';
import 'navigation_menu.dart';
import 'utils/constants/colors.dart';
import 'utils/theme/theme.dart';
import 'features/authentication/screens/splash/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialBinding: GeneralBinding(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/NavigationMenu', page: () => const NavigationMenu()),
        GetPage(name: '/Login', page: () => const LoginScreen()),
      ],
      // Handle unknown routes gracefully to prevent restoration errors
      onUnknownRoute: (settings) {
        // Return to home screen if route restoration fails
        return GetPageRoute(
          settings: settings,
          page: () => const Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
        );
      },

      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const SplashScreen(),
    );
  }
}
