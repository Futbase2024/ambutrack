import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:ambutrack_web/features/servicios/servicios/presentation/widgets/gestion/servicio_gestion_columns.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_bloc.dart';
import 'package:ambutrack_web/features/tablas/tipos_vehiculo/presentation/bloc/tipo_vehiculo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pestaña "General" de la ficha del servicio
class ServicioGeneralTab extends StatelessWidget {
  const ServicioGeneralTab({required this.servicio, super.key});

  final ServicioEntity servicio;

  @override
  Widget build(BuildContext context) {
    final ServicioEntity s = servicio;
    final PacienteEntity? p = s.paciente;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Servicio'),
        GestionDetailField(label: 'Código', value: s.codigo),
        GestionDetailField(
          label: 'Estado',
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestionDotLabel(
              label: ServicioGestion.estadoLabel(s.estado),
              color: ServicioGestion.estadoColor(s.estado),
            ),
          ),
        ),
        GestionDetailField(label: 'Tipo servicio', value: s.motivoTraslado?.nombre),
        _TipoAmbulanciaField(tipoId: s.tipoAmbulancia),
        const GestionDetailSection(title: 'Programación'),
        GestionDetailField(label: 'Recurrencia', value: s.tipoRecurrencia?.toUpperCase()),
        GestionDetailField(label: 'Días', value: _diasSemana(s.diasSemana)),
        GestionDetailField(label: 'Inicio', value: GestionFormatters.fecha(s.fechaServicioInicio)),
        GestionDetailField(label: 'Fin', value: GestionFormatters.fecha(s.fechaServicioFin)),
        GestionDetailField(label: 'Hora en centro', value: _hora(s.horaRecogida)),
        GestionDetailField(label: 'Hora vuelta', value: s.requiereVuelta ? _hora(s.horaVuelta) : 'Sin vuelta'),
        const GestionDetailSection(title: 'Trayecto'),
        GestionDetailField(label: 'Origen', value: ServicioGestion.origen(s)),
        GestionDetailField(label: 'Destino', value: ServicioGestion.destino(s)),
        const GestionDetailSection(title: 'Paciente'),
        GestionDetailField(label: 'Nombre', value: p?.nombreCompleto),
        GestionDetailField(
          label: p?.tipoDocumento ?? 'Documento',
          value: p == null || p.documento.isEmpty ? null : p.documento,
        ),
        GestionDetailField(label: 'Nacimiento', value: GestionFormatters.fecha(p?.fechaNacimiento)),
        GestionDetailField(label: 'Domicilio', value: p?.domicilioDireccion),
        const GestionDetailSection(title: 'Requisitos'),
        GestionDetailField(label: 'Necesita ayuda', value: s.requiereAyuda ? 'Sí' : 'No'),
        GestionDetailField(label: 'Equipamiento', value: _requisitos(s)),
      ],
    );
  }

  /// Días ISO 8601: 1 = lunes ... 7 = domingo
  static String? _diasSemana(List<int>? dias) {
    if (dias == null || dias.isEmpty) {
      return null;
    }
    const List<String> nombres = <String>['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return dias.where((int d) => d >= 1 && d <= 7).map((int d) => nombres[d]).join(', ');
  }

  /// "HH:MM:SS" → "HH:MM"
  static String? _hora(String? hora) {
    if (hora == null || hora.isEmpty) {
      return null;
    }
    return hora.length >= 5 ? hora.substring(0, 5) : hora;
  }

  static String _requisitos(ServicioEntity s) {
    final List<String> items = <String>[
      if (s.requiereSillaRuedas) 'Silla de ruedas',
      if (s.requiereCamilla) 'Camilla',
      if (s.requiereAcompanante) 'Acompañante',
    ];
    return items.isEmpty ? 'Ninguno' : items.join(', ');
  }
}

/// Fila "Ambulancia" con el nombre del tipo a partir de su id (tabla maestra)
class _TipoAmbulanciaField extends StatelessWidget {
  const _TipoAmbulanciaField({required this.tipoId});

  final String? tipoId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TipoVehiculoBloc, TipoVehiculoState>(
      builder: (BuildContext context, TipoVehiculoState state) {
        String? nombre;
        if (tipoId == null) {
          nombre = null;
        } else if (state is TipoVehiculoLoaded) {
          nombre = state.tiposVehiculo
                  .where((TipoVehiculoEntity t) => t.id == tipoId)
                  .map((TipoVehiculoEntity t) => t.nombre)
                  .firstOrNull ??
              'Tipo desconocido';
        } else {
          nombre = 'Cargando...';
        }
        return GestionDetailField(label: 'Ambulancia', value: nombre);
      },
    );
  }
}
