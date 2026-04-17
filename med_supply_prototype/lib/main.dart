import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Step 2: ProviderScope wrapping the entire app for state management
    const ProviderScope(
      child: MedSupplyApp(),
    ),
  );
}

class MedSupplyApp extends ConsumerWidget {
  const MedSupplyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch global routerProvider for auth-reactive navigation
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MedSupply',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Updated Medical Emerald Primary
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          color: Colors.white,
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      
      routerConfig: router,
    );
  }
}
