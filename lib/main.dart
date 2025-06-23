// lib/main_with_migration.dart
// MODIFICACIONES MÍNIMAS: Solo agregar migración a tu main.dart existente

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'config/routes.dart'; // CAMBIAR por: import 'config/routes_fixed.dart' as AppRoutes;
import 'config/themes.dart';
import 'providers/auth_provider.dart';
import 'providers/classroom_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/student_provider.dart';
import 'providers/avatar_provider.dart';
import 'providers/coin_provider.dart';
import 'providers/booster_provider.dart';
import 'screens/auth/login_screen.dart';
import 'services/graphql_service.dart';
// AGREGAR ESTAS LÍNEAS:
import 'services/lesson_migration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive para GraphQL Flutter
  await initHiveForFlutter();
  
  // Orientación vertical forzada
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Obtener el cliente GraphQL
  final clientNotifier = await GraphQLService.getClientNotifier();
  
  runApp(MyApp(clientNotifier: clientNotifier));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> clientNotifier;
  
  const MyApp({super.key, required this.clientNotifier});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: clientNotifier,
      child: MultiProvider(
        providers: [
          Provider<GraphQLClient>.value(value: clientNotifier.value),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) {
            final client = clientNotifier.value;
            return AuthProvider(client);
          }),
          ChangeNotifierProvider(create: (context) {
            final client = Provider.of<GraphQLClient>(context, listen: false);
            return ClassroomProvider(client);
          }),
          ChangeNotifierProvider(create: (context) {
            final client = Provider.of<GraphQLClient>(context, listen: false);
            return StudentProvider(client);
          }),
          ChangeNotifierProvider(create: (context) {
            return AvatarProvider();
          }),
          ChangeNotifierProvider(create: (context) {
            return CoinProvider();
          }),
          ChangeNotifierProvider(create: (context) {
            return BoosterProvider();
          }),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              title: 'Colegio Los Ángeles',
              debugShowCheckedModeBanner: false,
              theme: themeProvider.isDarkMode
                ? AppThemes.darkTheme
                : AppThemes.lightTheme,
              routes: AppRoutes.routes, // CAMBIAR por: routes: AppRoutes.routes,
              // AGREGAR ESTA LÍNEA:
              home: AppInitializerWrapper(),
            );
          },
        ),
      ),
    );
  }
}

// AGREGAR ESTA CLASE NUEVA:
/// Wrapper para inicializar migración automática sin afectar el flujo actual
class AppInitializerWrapper extends StatefulWidget {
  const AppInitializerWrapper({super.key});

  @override
  State<AppInitializerWrapper> createState() => _AppInitializerWrapperState();
}

class _AppInitializerWrapperState extends State<AppInitializerWrapper> {
  @override
  void initState() {
    super.initState();
    // Inicializar migración en segundo plano después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMigrationSilently();
    });
  }

  /// Inicializar migración en segundo plano sin afectar la UI
  void _initializeMigrationSilently() async {
    try {
      // Esperar un poco para que la app termine de cargar
      await Future.delayed(const Duration(seconds: 2));
      
      // Verificar si hay un estudiante logueado
      if (mounted) {
        final studentProvider = Provider.of<StudentProvider>(context, listen: false);
        
        // Solo inicializar si hay datos del estudiante
        if (studentProvider.level > 0) {
          print('🔄 Inicializando migración GraphQL en segundo plano...');
          
          // Inicializar migración silenciosamente
          LessonMigrationService.initializeMigration(1).catchError((e) {
            print('⚠️ Error en migración automática (no crítico): $e');
          });
        }
      }
    } catch (e) {
      print('⚠️ Error inicializando migración: $e');
      // No hacer nada, la migración es opcional
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simplemente mostrar la pantalla de login como antes
    return const LoginScreen();
  }
}