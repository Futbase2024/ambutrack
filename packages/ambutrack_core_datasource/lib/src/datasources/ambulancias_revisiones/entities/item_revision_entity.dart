/// Entity para Item de Revisión
class ItemRevisionEntity {
  const ItemRevisionEntity({
    required this.id,
    required this.revisionId,
    this.equipoId,
    this.medicamentoId,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    this.cantidadEsperada,
    required this.verificado,
    this.conforme,
    this.cantidadEncontrada,
    this.observaciones,
    required this.requiereReposicion,
    this.fechaCaducidad,
    this.caducado,
    this.verificadoEn,
    this.verificadoPor,
    required this.createdAt,
  });

  final String id;
  final String revisionId;
  final String? equipoId;
  final String? medicamentoId;
  final String categoriaId;
  final String nombre;
  final String? descripcion;
  final int? cantidadEsperada;
  final bool verificado;
  final bool? conforme; // true = OK, false = No conforme, null = no verificado
  final int? cantidadEncontrada;
  final String? observaciones;
  final bool requiereReposicion;
  final DateTime? fechaCaducidad;
  final bool? caducado;
  final DateTime? verificadoEn;
  final String? verificadoPor;
  final DateTime createdAt;

  /// Verifica si el item tiene caducidad
  bool get tieneCaducidad => fechaCaducidad != null;

  /// Verifica si el item está vencido o próximo a vencer
  bool get estaVencido {
    if (fechaCaducidad == null) return false;
    return fechaCaducidad!.isBefore(DateTime.now());
  }

  /// Días hasta el vencimiento
  int? get diasHastaVencimiento {
    if (fechaCaducidad == null) return null;
    return fechaCaducidad!.difference(DateTime.now()).inDays;
  }

  /// Crea una copia con los campos modificados
  ItemRevisionEntity copyWith({
    String? id,
    String? revisionId,
    String? equipoId,
    String? medicamentoId,
    String? categoriaId,
    String? nombre,
    String? descripcion,
    int? cantidadEsperada,
    bool? verificado,
    bool? conforme,
    int? cantidadEncontrada,
    String? observaciones,
    bool? requiereReposicion,
    DateTime? fechaCaducidad,
    bool? caducado,
    DateTime? verificadoEn,
    String? verificadoPor,
    DateTime? createdAt,
  }) {
    return ItemRevisionEntity(
      id: id ?? this.id,
      revisionId: revisionId ?? this.revisionId,
      equipoId: equipoId ?? this.equipoId,
      medicamentoId: medicamentoId ?? this.medicamentoId,
      categoriaId: categoriaId ?? this.categoriaId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      cantidadEsperada: cantidadEsperada ?? this.cantidadEsperada,
      verificado: verificado ?? this.verificado,
      conforme: conforme ?? this.conforme,
      cantidadEncontrada: cantidadEncontrada ?? this.cantidadEncontrada,
      observaciones: observaciones ?? this.observaciones,
      requiereReposicion: requiereReposicion ?? this.requiereReposicion,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      caducado: caducado ?? this.caducado,
      verificadoEn: verificadoEn ?? this.verificadoEn,
      verificadoPor: verificadoPor ?? this.verificadoPor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
