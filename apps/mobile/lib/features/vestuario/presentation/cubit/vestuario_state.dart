import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

enum VestuarioStatus { cargando, listo, error }

/// Estado de "Mi vestuario"
class VestuarioState extends Equatable {
  const VestuarioState({
    this.status = VestuarioStatus.cargando,
    this.prendas = const <VestuarioEntity>[],
    this.solicitudes = const <SolicitudVestuarioEntity>[],
    this.catalogo = const <PrendaCatalogoEntity>[],
    this.tallas,
    this.guardando = false,
    this.error,
  });

  final VestuarioStatus status;
  final List<VestuarioEntity> prendas;
  final List<SolicitudVestuarioEntity> solicitudes;
  final List<PrendaCatalogoEntity> catalogo;
  final TallasPersonalEntity? tallas;

  /// Guardando tallas o enviando una solicitud
  final bool guardando;
  final String? error;

  /// Prendas que el trabajador tiene ahora
  List<VestuarioEntity> get prendasActivas => prendas.where((VestuarioEntity p) => p.activo).toList();

  /// Prendas devueltas o dadas de baja
  List<VestuarioEntity> get prendasHistorial => prendas.where((VestuarioEntity p) => !p.activo).toList();

  int get solicitudesAbiertas => solicitudes.where((SolicitudVestuarioEntity s) => s.estado.abierta).length;

  /// Nombres de prenda del almacén (sin repetir)
  List<String> get prendasCatalogo => catalogo.map((PrendaCatalogoEntity c) => c.prenda).toSet().toList()..sort();

  /// Tallas que hay en almacén para una prenda
  List<PrendaCatalogoEntity> tallasDe(String prenda) =>
      catalogo.where((PrendaCatalogoEntity c) => c.prenda.toUpperCase() == prenda.toUpperCase()).toList();

  /// La prenda ya tiene una solicitud abierta (evita duplicados)
  bool tieneSolicitudAbierta(String vestuarioId) =>
      solicitudes.any((SolicitudVestuarioEntity s) => s.vestuarioId == vestuarioId && s.estado.abierta);

  VestuarioState copyWith({
    VestuarioStatus? status,
    List<VestuarioEntity>? prendas,
    List<SolicitudVestuarioEntity>? solicitudes,
    List<PrendaCatalogoEntity>? catalogo,
    TallasPersonalEntity? tallas,
    bool? guardando,
    String? error,
  }) {
    return VestuarioState(
      status: status ?? this.status,
      prendas: prendas ?? this.prendas,
      solicitudes: solicitudes ?? this.solicitudes,
      catalogo: catalogo ?? this.catalogo,
      tallas: tallas ?? this.tallas,
      guardando: guardando ?? this.guardando,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, prendas, solicitudes, catalogo, tallas, guardando, error];
}
