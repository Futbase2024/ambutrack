import 'package:flutter/material.dart';
import 'tipo_ubicacion.dart';

/// Datos de un trayecto (origen → destino)
class TrayectoData {
  TrayectoData({
    this.tipoOrigen = TipoUbicacion.domicilioPaciente,
    this.tipoDestino = TipoUbicacion.centroHospitalario,
    this.origenDomicilio,
    this.origenCentro,
    this.origenUbicacionEnCentro,
    this.destinoDomicilio,
    this.destinoCentro,
    this.destinoUbicacionEnCentro,
    this.hora,
    this.horaController,
  });

  // Tipo de ubicación para origen y destino
  TipoUbicacion tipoOrigen;
  TipoUbicacion tipoDestino;

  // Origen
  String? origenDomicilio; // Si es otro domicilio
  String? origenCentro; // Si es centro hospitalario
  String? origenUbicacionEnCentro; // Ubicación dentro del centro (ej: Urgencias, Hab-202)

  // Destino
  String? destinoDomicilio; // Si es otro domicilio
  String? destinoCentro; // Si es centro hospitalario
  String? destinoUbicacionEnCentro; // Ubicación dentro del centro (ej: Urgencias, Hab-202)

  // Hora
  TimeOfDay? hora;
  TextEditingController? horaController;

  /// Obtiene el origen como string para mostrar
  String? get origenDisplay {
    switch (tipoOrigen) {
      case TipoUbicacion.domicilioPaciente:
        return 'Domicilio del paciente';
      case TipoUbicacion.otroDomicilio:
        return origenDomicilio;
      case TipoUbicacion.centroHospitalario:
        return origenCentro;
    }
  }

  /// Obtiene el destino como string para mostrar
  String? get destinoDisplay {
    switch (tipoDestino) {
      case TipoUbicacion.domicilioPaciente:
        return 'Domicilio del paciente';
      case TipoUbicacion.otroDomicilio:
        return destinoDomicilio;
      case TipoUbicacion.centroHospitalario:
        return destinoCentro;
    }
  }

  /// Limpia el controller al destruir
  void dispose() {
    horaController?.dispose();
  }
}
