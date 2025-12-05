import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partController = TextEditingController();
  final _orderController = TextEditingController();
  final _qtyController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  ItemStatus _selectedStatus = ItemStatus.ok;
  bool _isProcessing = false;

  // Simulación de OCR (En una app real usaríamos google_ml_kit_text_recognition)
  Future<void> _processImage(XFile image) async {
    setState(() {
      _isProcessing = true;
      _imageFile = File(image.path);
    });

    // SIMULACIÓN: Esperamos un poco para simular el proceso de lectura
    await Future.delayed(const Duration(seconds: 2));

    // SIMULACIÓN: Generamos datos aleatorios o extraemos "mock" data
    // En producción, aquí iría: final recognizedText = await textRecognizer.processImage(...);
    
    // Lógica requerida: Detectar pieza que empieza con "p"
    // Vamos a simular que encontramos un texto
    String mockDetectedPart = "p${Random().nextInt(9000) + 1000}"; 
    String mockDetectedOrder = "${Random().nextInt(9000)}-${Random().nextInt(900)}";
    String mockDetectedQty = "${Random().nextInt(50) + 1}";

    if (mounted) {
      setState(() {
        _partController.text = mockDetectedPart;
        _orderController.text = mockDetectedOrder;
        _qtyController.text = mockDetectedQty;
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Texto extraído con éxito (Simulado)')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        await _processImage(photo);
      }
    } catch (e) {
      // Fallback para web o simulador sin cámara
      _simulateScan();
    }
  }

  void _simulateScan() {
    // Función auxiliar para probar sin cámara real
    _processImage(XFile('path/to/mock'));
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      final newItem = InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        partNumber: _partController.text,
        orderNumber: _orderController.text,
        quantity: int.parse(_qtyController.text),
        status: _selectedStatus,
        imageUrl: _imageFile?.path,
      );

      InventoryService().addItem(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pieza ${_partController.text} guardada en ${_selectedStatus == ItemStatus.scrap ? "Desecho" : "Inventario"}'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Pieza')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Área de la foto
              GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            Text('Tocar para tomar foto'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 10),
              if (_isProcessing)
                const LinearProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera),
                  label: const Text('Escanear Texto (OCR)'),
                ),
              
              const SizedBox(height: 20),
              const Text('Datos Extraídos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),

              // Campo Pieza
              TextFormField(
                controller: _partController,
                decoration: const InputDecoration(
                  labelText: 'Número de Pieza',
                  hintText: 'Ej: p2356',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.settings),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (!value.toLowerCase().startsWith('p')) {
                    return 'La pieza debe empezar con "p"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Campo Pedido
              TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(
                  labelText: 'Número de Pedido',
                  hintText: 'Ej: 4567-234',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment),
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),

              // Campo Cantidad
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Selector de Estado (Cuarentena/Desecho)
              const Text('Estado de la Pieza:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              SegmentedButton<ItemStatus>(
                segments: const [
                  ButtonSegment(value: ItemStatus.ok, label: Text('OK'), icon: Icon(Icons.check)),
                  ButtonSegment(value: ItemStatus.quarantine, label: Text('Cuarentena'), icon: Icon(Icons.warning)),
                  ButtonSegment(value: ItemStatus.scrap, label: Text('Desecho'), icon: Icon(Icons.delete)),
                ],
                selected: {_selectedStatus},
                onSelectionChanged: (Set<ItemStatus> newSelection) {
                  setState(() {
                    _selectedStatus = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return _selectedStatus == ItemStatus.ok ? Colors.green.shade100 :
                             _selectedStatus == ItemStatus.quarantine ? Colors.orange.shade100 :
                             Colors.red.shade100;
                    }
                    return null;
                  }),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _saveItem,
                  child: const Text('GUARDAR EN EXCEL', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
