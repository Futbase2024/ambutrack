import 'package:equatable/equatable.dart';

/// Indicador clave (tile de la fila de KPIs)
class InformeKpi extends Equatable {
  const InformeKpi({
    required this.label,
    required this.valor,
    this.detalle,
  });

  final String label;

  /// Valor ya formateado
  final String valor;

  /// Texto secundario opcional (p. ej. "de 120 servicios")
  final String? detalle;

  @override
  List<Object?> get props => <Object?>[label, valor, detalle];
}

/// Barra de un gráfico de barras horizontal
class InformeBarItem extends Equatable {
  const InformeBarItem({
    required this.label,
    required this.valor,
    required this.texto,
  });

  final String label;

  /// Valor numérico (determina la longitud de la barra)
  final double valor;

  /// Valor formateado que se muestra junto a la barra
  final String texto;

  @override
  List<Object?> get props => <Object?>[label, valor, texto];
}

/// Datos de impresión (cabeceras + filas de la tabla principal)
class InformeImpresion {
  const InformeImpresion({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;
}
