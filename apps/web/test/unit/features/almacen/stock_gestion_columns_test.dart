import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/features/almacen/presentation/widgets/gestion/stock_gestion_columns.dart';
import 'package:flutter_test/flutter_test.dart';

StockEntity _stock({
  String id = 's1',
  String producto = 'p1',
  double actual = 10,
  double minima = 5,
  DateTime? caducidad,
  String? lote,
  String? ubicacion,
}) {
  final DateTime ahora = DateTime(2026);
  return StockEntity(
    id: id,
    idAlmacen: 'a1',
    idProducto: producto,
    cantidadActual: actual,
    cantidadMinima: minima,
    fechaCaducidad: caducidad,
    lote: lote,
    ubicacionFisica: ubicacion,
    createdAt: ahora,
    updatedAt: ahora,
  );
}

void main() {
  final DateTime hoy = DateTime.now();
  final Map<String, ProductoEntity> productos = <String, ProductoEntity>{
    'p1': const ProductoEntity(id: 'p1', nombre: 'IBUPROFENO', categoria: CategoriaProducto.medicacion),
    'p2': const ProductoEntity(id: 'p2', nombre: 'DESA', categoria: CategoriaProducto.electromedicina),
  };

  group('StockSituacion.de', () {
    test('caducado tiene prioridad sobre stock bajo', () {
      final StockEntity s = _stock(actual: 1, caducidad: hoy.subtract(const Duration(days: 2)));
      expect(StockSituacion.de(s), StockSituacion.caducado);
    });

    test('próximo a caducar (dentro de 30 días)', () {
      final StockEntity s = _stock(caducidad: hoy.add(const Duration(days: 10)));
      expect(StockSituacion.de(s), StockSituacion.proximoCaducar);
    });

    test('stock bajo cuando la cantidad es menor que el mínimo', () {
      expect(StockSituacion.de(_stock(actual: 2)), StockSituacion.bajo);
    });

    test('OK en el resto de casos', () {
      expect(StockSituacion.de(_stock(caducidad: hoy.add(const Duration(days: 200)))), StockSituacion.ok);
    });
  });

  group('filtrarStock', () {
    final List<StockEntity> items = <StockEntity>[
      _stock(lote: 'L-ABC', ubicacion: 'Estante 1'),
      _stock(id: 's2', producto: 'p2', actual: 1),
    ];

    test('busca por nombre de producto, lote y ubicación sin distinguir mayúsculas', () {
      expect(filtrarStock(items, productos: productos, query: 'ibu', categoria: null, situacion: null).length, 1);
      expect(filtrarStock(items, productos: productos, query: 'l-abc', categoria: null, situacion: null).length, 1);
      expect(filtrarStock(items, productos: productos, query: 'estante', categoria: null, situacion: null).length, 1);
    });

    test('filtra por categoría del producto', () {
      final List<StockEntity> r = filtrarStock(
        items,
        productos: productos,
        query: '',
        categoria: CategoriaProducto.electromedicina,
        situacion: null,
      );
      expect(r.single.id, 's2');
    });

    test('filtra por situación', () {
      final List<StockEntity> r = filtrarStock(
        items,
        productos: productos,
        query: '',
        categoria: null,
        situacion: StockSituacion.bajo,
      );
      expect(r.single.id, 's2');
    });
  });

  test('stockProducto avisa si el producto no existe', () {
    expect(stockProducto(_stock(producto: 'x'), productos), 'Producto no encontrado');
  });
}
