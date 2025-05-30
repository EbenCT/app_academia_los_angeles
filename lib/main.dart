import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'config/routes.dart';
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
            // Pasar el cliente GraphQL al AuthProvider
            final client = clientNotifier.value;
            return AuthProvider(client);
          }),
          ChangeNotifierProvider(create: (context) {
            // Accedemos directamente al GraphQLClient que expusimos arriba
            final client = Provider.of<GraphQLClient>(context, listen: false);
            return ClassroomProvider(client);
          }),
          // Añade el StudentProvider
          ChangeNotifierProvider(create: (context) {
            // Accedemos directamente al GraphQLClient que expusimos arriba
            final client = Provider.of<GraphQLClient>(context, listen: false);
            return StudentProvider(client);
          }),
          // Añade el AvatarProvider (actualizado)
          ChangeNotifierProvider(create: (context) {
            return AvatarProvider();
          }),
          // Añade el CoinProvider
          ChangeNotifierProvider(create: (context) {
            return CoinProvider();
          }),
          // Añade el BoosterProvider
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
              routes: AppRoutes.routes,
              home: const LoginScreen(),
            );
          },
        ),
      ),
    );
  }
}