import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/location_provider.dart';
import 'package:invenicum/services/asset_type_service.dart';
import 'package:invenicum/services/container_service.dart';
import 'package:invenicum/services/inventory_item_service.dart';
import 'package:invenicum/services/location_service.dart';
import 'routing/app_router.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // kIsWeb (de foundation.dart) garantiza que esto solo se ejecute en web.
    BrowserContextMenu.disableContextMenu();
  }
  runApp(
    MultiProvider(
      providers: [
        // 1. Provee el ApiService (Configuración base de Dio)
        Provider(create: (_) => ApiService()), // Asegúrate de pasar la URL base
        // 2. Provee el ContainerService, inyectando el ApiService
        Provider(
          create: (context) => ContainerService(context.read<ApiService>()),
        ),
        Provider(
          create: (context) => LocationService(context.read<ApiService>()),
        ),
        // 3. AÑADIDO: Provee el AssetTypeService, inyectando el ApiService
        Provider(
          create: (context) => AssetTypeService(context.read<ApiService>()),
        ),
        Provider(
          create: (context) => InventoryItemService(context.read<ApiService>()),
        ),

        // 4. MODIFICADO: Provee el ContainerProvider, inyectando AMBOS servicios
        ChangeNotifierProvider(
          create: (context) => ContainerProvider(
            context.read<ContainerService>(),
            context.read<AssetTypeService>(),
            context.read<LocationService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LocationProvider(
            context.read<LocationService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              InventoryItemProvider(context.read<InventoryItemService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: [
        // El delegado generado a partir de tus archivos .arb
        AppLocalizations.delegate,
    
        // Delegados de Flutter estándar (para textos de Material, como botones 'OK')
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    
      // 2. Idiomas Soportados
      supportedLocales: AppLocalizations.supportedLocales,
      builder: FToastBuilder(),
      debugShowCheckedModeBanner: false,
      title: 'Invenicum',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
