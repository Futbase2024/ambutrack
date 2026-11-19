import 'package:equatable/equatable.dart';

/// Tipo de solicitud de vestuario
enum TipoSolicitudVestuario {
  nueva('nueva', 'Prenda nueva'),
  reposicion('reposicion', 'Reposición (desgaste o rotura)'),
  cambioTalla('cambio_talla', 'Cambio de talla'),
  devolucion('devolucion', 'Devolución');

  const TipoSolicitudVestuario(this.value, this.label);

  final String value;
  final String label;

  /// Necesita indicar qué prenda de las suyas se sustituye o devuelve
  bool get requierePrendaActual => this != nueva;

  /// Se entrega una prenda del almacén
  bool get entregaPrenda => this != devolucion;

  static TipoSolicitudVestuario fromString(String? value) {
    return TipoSolicitudVestuario.values.firstWhere(
      (TipoSolicitudVestuario t) => t.value == value,
      orElse: () => TipoSolicitudVestuario.nueva,
    );
  }
}

/// Estado de una solicitud de vestuario
enum EstadoSolicitudVestuario {
  pendiente('pendiente', 'Pendiente'),
  aprobada('aprobada', 'Aprobada'),
  rechazada('rechazada', 'Rechazada'),
  entregada('entregada', 'Entregada'),
  cancelada('cancelada', 'Cancelada');

  const EstadoSolicitudVestuario(this.value, this.label);

  final String value;
  final String label;

  /// Aún la puede gestionar almacén
  bool get abierta => this == pendiente || this == aprobada;

  static EstadoSolicitudVestuario fromString(String? value) {
    return EstadoSolicitudVestuario.values.firstWhere(
      (EstadoSolicitudVestuario e) => e.value == value,
      orElse: () => EstadoSolicitudVestuario.pendiente,
    );
  }
}

/// Entity: solicitud de vestuario de un trabajador (tabla `solicitudes_vestuario`)
///
/// `empresaId`, `personalNombre`, `estado` inicial y los campos de gestión los fija la BD.
class SolicitudVestuarioEntity extends Equatable {
  const SolicitudVestuarioEntity({
    required this.id,
    required this.personalId,
    required this.tipo,
    required this.prenda,
    this.talla,
    this.cantidad = 1,
    this.motivo,
    this.fotoUrl,
    this.vestuarioId,
    this.personalNombre,
    this.estado = EstadoSolicitudVestuario.pendiente,
    this.stockVestuarioId,
    this.vestuarioEntregadoId,
    this.motivoRechazo,
    this.gestionadoPor,
    this.gestionadoAt,
    this.entregadoAt,
    this.createdAt,
  });

  final String id;
  final String personalId;
  final TipoSolicitudVestuario tipo;
  final String prenda;
  final String? talla;
  final int cantidad;
  final String? motivo;

  /// Ruta en el bucket privado `vestuario-fotos`
  final String? fotoUrl;

  /// Prenda del trabajador que se sustituye o devuelve
  final String? vestuarioId;
  final String? personalNombre;
  final EstadoSolicitudVestuario estado;
  final String? stockVestuarioId;
  final String? vestuarioEntregadoId;
  final String? motivoRechazo;
  final String? gestionadoPor;
  final DateTime? gestionadoAt;
  final DateTime? entregadoAt;
  final DateTime? createdAt;

  @override
  List<Object?> get props => <Object?>[
        id,
        personalId,
        tipo,
        prenda,
        talla,
        cantidad,
        motivo,
        fotoUrl,
        vestuarioId,
        personalNombre,
        estado,
        stockVestuarioId,
        vestuarioEntregadoId,
        motivoRechazo,
        gestionadoPor,
        gestionadoAt,
        entregadoAt,
        createdAt,
      ];
}

/// Prenda y talla disponibles en almacén (RPC `fn_catalogo_vestuario`)
class PrendaCatalogoEntity extends Equatable {
  const PrendaCatalogoEntity({required this.prenda, required this.talla, required this.disponible});

  final String prenda;
  final String talla;
  final int disponible;

  @override
  List<Object?> get props => <Object?>[prenda, talla, disponible];
}

/// Tallas del trabajador (tabla `tallas_personal`)
class TallasPersonalEntity extends Equatable {
  const TallasPersonalEntity({
    required this.personalId,
    this.camiseta,
    this.polo,
    this.sudadera,
    this.chaqueta,
    this.pantalon,
    this.calzado,
    this.guantes,
    this.observaciones,
    this.updatedAt,
  });

  final String personalId;
  final String? camiseta;
  final String? polo;
  final String? sudadera;
  final String? chaqueta;
  final String? pantalon;
  final String? calzado;
  final String? guantes;
  final String? observaciones;
  final DateTime? updatedAt;

  /// Talla habitual para una prenda (por nombre aproximado), si la tiene registrada
  String? tallaPara(String prenda) {
    final String p = prenda.toUpperCase();
    if (p.contains('CAMISETA')) {
      return camiseta;
    }
    if (p.contains('POLO')) {
      return polo;
    }
    if (p.contains('SUDADERA') || p.contains('FORRO')) {
      return sudadera;
    }
    if (p.contains('CHAQUETA') || p.contains('CAZADORA') || p.contains('PARKA') || p.contains('ABRIGO')) {
      return chaqueta;
    }
    if (p.contains('PANTAL')) {
      return pantalon;
    }
    if (p.contains('BOTA') || p.contains('ZAPAT') || p.contains('CALZADO')) {
      return calzado;
    }
    if (p.contains('GUANTE')) {
      return guantes;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
        personalId,
        camiseta,
        polo,
        sudadera,
        chaqueta,
        pantalon,
        calzado,
        guantes,
        observaciones,
        updatedAt,
      ];
}
