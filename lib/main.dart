import 'package:flutter/material.dart';
import 'package:srpski_padezi/screens/home_screen.dart';
import 'package:srpski_padezi/services/progress_service.dart';
import 'package:srpski_padezi/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressService.instance.load();
  runApp(const SrpskiPadeziApp());
}

class SrpskiPadeziApp extends StatelessWidget {
  const SrpskiPadeziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Srpski Padeži',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
