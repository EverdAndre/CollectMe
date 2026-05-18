import 'package:collection_app/data/datasources/collection_datasource.dart';
import 'package:collection_app/pages/collection_home_screen.dart';
import 'package:collection_app/pages/collection_relatorio_screen.dart';
import 'package:collection_app/pages/collection_sobre_screen.dart';
import 'package:collection_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prepara o SQLite FFI antes de qualquer tela tentar acessar os dados.
  CollectionDataSource.initDatabaseFactory();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CollectMe',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Rotas principais usadas pelos menus da Home.
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const CollectionHomeScreen(),
        AppRoutes.about: (context) => const CollectionSobreScreen(),
        AppRoutes.relatorio: (context) => const CollectionRelatorioScreen(),
      },
    );
  }
}
