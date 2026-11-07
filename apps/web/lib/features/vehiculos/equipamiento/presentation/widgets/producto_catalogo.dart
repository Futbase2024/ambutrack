import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:ambutrack_web/features/almacen/domain/repositories/producto_repository.dart';

/// Catálogo de productos activos (tabla `productos`) ordenado por nombre
Future<List<ProductoEntity>> cargarCatalogoProductos() async {
  final List<ProductoEntity> productos = await getIt<ProductoRepository>().getAll();
  return productos.where((ProductoEntity p) => p.activo).toList()
    ..sort((ProductoEntity a, ProductoEntity b) => a.nombre.compareTo(b.nombre));
}

/// Texto visible de un producto en los buscadores
String productoLabel(ProductoEntity p) {
  final String codigo = p.codigo == null || p.codigo!.isEmpty ? '' : '[${p.codigo}] ';
  final String comercial =
      p.nombreComercial == null || p.nombreComercial!.isEmpty ? '' : ' (${p.nombreComercial})';
  return '$codigo${p.nombre}$comercial';
}

/// Opciones para `GestionSearchField` (verde = tiene caducidad)
List<GestionOption<ProductoEntity>> opcionesProductos(List<ProductoEntity> productos) {
  return productos
      .map(
        (ProductoEntity p) => GestionOption<ProductoEntity>(
          p,
          productoLabel(p),
          color: p.tieneCaducidad ? AppColors.warning : AppColors.success,
        ),
      )
      .toList();
}
