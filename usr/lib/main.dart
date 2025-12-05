import 'package:flutter/material.dart';
import 'screens/scan_screen.dart';
import 'screens/table_screen.dart';
import 'services/inventory_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Inventario OCR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/scan': (context) => const ScanScreen(),
        '/table': (context) => const InventoryTableScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Piezas'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo o Icono Grande
            const Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Bienvenido al Sistema',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Escanea piezas y genera reportes Excel',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Botón Escanear
            SizedBox(
              width: 250,
              height: 60,
              child: FilledButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/scan'),
                icon: const Icon(Icons.camera_alt),
                label: const Text('NUEVA FOTOGRAFÍA', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),

            // Botón Ver Excel
            SizedBox(
              width: 250,
              height: 60,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/table'),
                icon: const Icon(Icons.table_view),
                label: const Text('VER EXCEL / DATOS', style: TextStyle(fontSize: 18)),
              ),
            ),
            
            const SizedBox(height: 40),
            // Resumen rápido
            ListenableBuilder(
              listenable: InventoryService(),
              builder: (context, _) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Inventario Actual:', style: TextStyle(fontSize: 16)),
                        Text(
                          '${InventoryService().currentInventoryCount} pzas',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
