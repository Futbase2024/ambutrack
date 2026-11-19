import 'package:equatable/equatable.dart';

/// Resultado de una ejecución de la generación de traslados
/// (función RPC `generar_traslados_periodo`)
class ResultadoGeneracionTrasladosEntity extends Equatable {
  const ResultadoGeneracionTrasladosEntity({
    required this.fechaDesde,
    required this.fechaHasta,
    required this.ejecutadoEn,
    this.serviciosProcesados = 0,
    this.trasladosGenerados = 0,
    this.trasladosIda = 0,
    this.trasladosVuelta = 0,
    this.serviciosConError = 0,
    this.errores = const <String>[],
  });

  /// Inicio del periodo generado
  final DateTime fechaDesde;

  /// Fin del periodo generado
  final DateTime fechaHasta;

  /// Momento en que se ejecutó la generación
  final DateTime ejecutadoEn;

  final int serviciosProcesados;
  final int trasladosGenerados;
  final int trasladosIda;
  final int trasladosVuelta;
  final int serviciosConError;
  final List<String> errores;

  /// Indica si la generación terminó con errores en algún servicio
  bool get tieneErrores => serviciosConError > 0 || errores.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
        fechaDesde,
        fechaHasta,
        ejecutadoEn,
        serviciosProcesados,
        trasladosGenerados,
        trasladosIda,
        trasladosVuelta,
        serviciosConError,
        errores,
      ];
}
