import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';

class InventoryTableScreen extends StatefulWidget {
  const InventoryTableScreen({super.key});

  @override
  State<InventoryTableScreen> createState() => _InventoryTableScreenState();
}

class _InventoryTableScreenState extends State<InventoryTableScreen> {
  final InventoryService _service = InventoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel / Reporte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exportando a Excel... (Simulado)')),
              );
            },
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: _service,
        builder: (context, child) {
          final items = _service.items;
          
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_chart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay datos en el Excel aún.'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Resumen Superior
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryCard('Total OK', _service.totalItemsOk.toString(), Colors.green),
                    _buildSummaryCard('Cuarentena', _service.totalItemsQuarantine.toString(), Colors.orange),
                    _buildSummaryCard('Desecho', _service.totalItemsScrap.toString(), Colors.red),
                  ],
                ),
              ),
              
              // Tabla tipo Excel
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                      columns: const [
                        DataColumn(label: Text('Fecha')),
                        DataColumn(label: Text('Pieza (P)')),
                        DataColumn(label: Text('Pedido')),
                        DataColumn(label: Text('Cant.')),
                        DataColumn(label: Text('Estado')),
                        DataColumn(label: Text('Acción')),
                      ],
                      rows: items.map((item) {
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((states) {
                            if (item.status == ItemStatus.scrap) return Colors.red.shade50;
                            if (item.status == ItemStatus.quarantine) return Colors.orange.shade50;
                            return null;
                          }),
                          cells: [
                            DataCell(Text(DateFormat('dd/MM/yy HH:mm').format(item.date))),
                            DataCell(Text(item.partNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(item.orderNumber)),
                            DataCell(Text(item.quantity.toString())),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: item.statusColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: item.statusColor),
                                ),
                                child: Text(
                                  item.statusText,
                                  style: TextStyle(color: item.statusColor, fontSize: 12),
                                ),
                              )
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
                                onPressed: () {
                                  _service.removeItem(item.id);
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}
