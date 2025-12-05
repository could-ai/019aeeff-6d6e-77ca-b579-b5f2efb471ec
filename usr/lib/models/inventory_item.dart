import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ItemStatus {
  ok,         // Pieza correcta
  quarantine, // Cuarentena (desperfecto leve o revisión)
  scrap       // Desecho (no sirve, se resta)
}

class InventoryItem {
  final String id;
  final DateTime date;
  final String partNumber; // Debe empezar con "p"
  final String orderNumber;
  final int quantity;
  final ItemStatus status;
  final String? imageUrl;

  InventoryItem({
    required this.id,
    required this.date,
    required this.partNumber,
    required this.orderNumber,
    required this.quantity,
    required this.status,
    this.imageUrl,
  });

  // Helper para mostrar el estado en texto
  String get statusText {
    switch (status) {
      case ItemStatus.ok:
        return 'OK';
      case ItemStatus.quarantine:
        return 'Cuarentena';
      case ItemStatus.scrap:
        return 'Desecho';
    }
  }

  // Helper para color del estado
  Color get statusColor {
    switch (status) {
      case ItemStatus.ok:
        return Colors.green;
      case ItemStatus.quarantine:
        return Colors.orange;
      case ItemStatus.scrap:
        return Colors.red;
    }
  }
}
