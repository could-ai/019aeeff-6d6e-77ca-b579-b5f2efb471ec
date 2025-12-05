import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class InventoryService extends ChangeNotifier {
  // Singleton pattern
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  final List<InventoryItem> _items = [];

  List<InventoryItem> get items => List.unmodifiable(_items);

  void addItem(InventoryItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Cálculos para el reporte
  int get totalItemsOk => _items
      .where((i) => i.status == ItemStatus.ok)
      .fold(0, (sum, item) => sum + item.quantity);

  int get totalItemsQuarantine => _items
      .where((i) => i.status == ItemStatus.quarantine)
      .fold(0, (sum, item) => sum + item.quantity);
      
  int get totalItemsScrap => _items
      .where((i) => i.status == ItemStatus.scrap)
      .fold(0, (sum, item) => sum + item.quantity);

  // El total neto (OK + Cuarentena - Desecho no se suma al inventario útil, pero se registra)
  // Según requerimiento: "Desecho... se restarian del total". 
  // Interpretación: Inventario Actual = OK + Cuarentena. (Desecho está fuera).
  int get currentInventoryCount => totalItemsOk + totalItemsQuarantine;
}
