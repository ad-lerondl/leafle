import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise les locales pour le formatage des dates
  await initializeDateFormatting('fr_FR', null);
  // Crée l'état et charge les données avant de lancer l'app pour éviter tout reset visuel
  final appState = AppState();
  await appState.ensureLoaded();
  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.appState});

  final AppState? appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Réutilise l'instance préchargée pour ne pas relancer un chargement asynchrone
      create: (context) => appState ?? AppState(),
      child: MaterialApp(
        title: 'Leafle - Bien-être',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',

          // Thème apaisant et naturel
          scaffoldBackgroundColor: const Color(0xFFF5F9F5),

          // AppBar personnalisé
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),

          // Boutons avec des coins arrondis
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),

          // Cards avec ombres douces
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Animations fluides
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        home: const _LifecycleGuard(child: HomeScreen()),
      ),
    );
  }
}

/// Observe le cycle de vie pour sauvegarder automatiquement l'état
class _LifecycleGuard extends StatefulWidget {
  const _LifecycleGuard({required this.child});
  final Widget child;

  @override
  State<_LifecycleGuard> createState() => _LifecycleGuardState();
}

class _LifecycleGuardState extends State<_LifecycleGuard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Sauvegarde sur pause/inactif/détaché pour éviter toute perte
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      final appState = context.read<AppState>();
      appState.saveData();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
