import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'config/routes.dart';
import 'config/themes.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
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
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) {
            // Pasar el cliente GraphQL al AuthProvider
            final client = clientNotifier.value;
            return AuthProvider(client);
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