import 'package:flutter/material.dart';
import 'package:srpski_padezi/screens/home_screen.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/services/theme_service.dart';
import 'package:srpski_padezi/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressService.instance.load();
  await ThemeService.instance.load();
  runApp(const SrpskiPadeziApp());
}

class SrpskiPadeziApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;

    return AnimatedBuilder(
      animation: themeService,
      builder: (context, _) => MaterialApp(
        title: 'Srpski Padeži',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeService.mode,
        home: const HomeScreen(),
      ),
    );
  }
}
