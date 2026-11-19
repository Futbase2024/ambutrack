import 'package:ambutrack_web/features/informes/domain/informe_filtro.dart';
import 'package:equatable/equatable.dart';

/// Estado de carga de un informe
enum InformeStatus { initial, loading, loaded, error }

/// Estado común de los informes: filtro activo + datos calculados [T]
class InformeState<T> extends Equatable {
  const InformeState({
    required this.filtro,
    this.status = InformeStatus.initial,
    this.data,
    this.message,
  });

  final InformeFiltro filtro;
  final InformeStatus status;

  /// Datos agregados del informe (null hasta la primera carga)
  final T? data;

  /// Mensaje de error
  final String? message;

  bool get isLoading => status == InformeStatus.loading || status == InformeStatus.initial;

  InformeState<T> copyWith({
    InformeFiltro? filtro,
    InformeStatus? status,
    T? data,
    String? message,
  }) {
    return InformeState<T>(
      filtro: filtro ?? this.filtro,
      status: status ?? this.status,
      data: data ?? this.data,
      message: message,
    );
  }

  @override
  List<Object?> get props => <Object?>[filtro, status, data, message];
}
