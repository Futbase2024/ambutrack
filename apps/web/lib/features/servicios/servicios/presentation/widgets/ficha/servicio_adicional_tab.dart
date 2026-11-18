import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/servicios/servicios/domain/entities/servicio_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pestaña "Adicional" de la ficha del servicio: observaciones y registro
class ServicioAdicionalTab extends StatelessWidget {
  const ServicioAdicionalTab({required this.servicio, super.key});

  final ServicioEntity servicio;

  static final DateFormat _fechaHora = DateFormat('dd/MM/yyyy HH:mm');

  /// Fechas guardadas en UTC: se muestran en hora local
  static String? _formato(DateTime? fecha) => fecha == null ? null : _fechaHora.format(fecha.toLocal());

  @override
  Widget build(BuildContext context) {
    final ServicioEntity s = servicio;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Observaciones'),
        GestionDetailField(label: 'Generales', value: s.observaciones),
        GestionDetailField(label: 'Médicas', value: s.observacionesMedicas),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Creado', value: _formato(s.createdAt)),
        GestionDetailField(label: 'Modificado', value: _formato(s.updatedAt)),
        if (s.archivedAt != null) GestionDetailField(label: 'Archivado', value: _formato(s.archivedAt)),
      ],
    );
  }
}
