import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';

/// Datos de un trámite (vacación o ausencia) preparados para pintar en listas
class TramiteItem {
  const TramiteItem({
    required this.id,
    required this.titulo,
    required this.icono,
    required this.color,
    required this.inicio,
    required this.fin,
    required this.dias,
    required this.estado,
    required this.esAusencia,
    required this.abrir,
  });

  factory TramiteItem.vacacion(VacacionesEntity v) {
    return TramiteItem(
      id: v.id,
      titulo: 'Vacaciones',
      icono: Icons.beach_access_outlined,
      color: AppColors.info,
      inicio: v.fechaInicio,
      fin: v.fechaFin,
      dias: v.diasSolicitados,
      estado: v.estado,
      esAusencia: false,
      abrir: (context) => context.push('/tramites/vacacion/${v.id}', extra: v),
    );
  }

  factory TramiteItem.ausencia(AusenciaEntity a, List<TipoAusenciaEntity> tipos) {
    final TipoAusenciaEntity tipo = tipos.firstWhere(
      (t) => t.id == a.idTipoAusencia,
      orElse: () => TipoAusenciaEntity(
        id: '',
        nombre: 'Ausencia',
        requiereAprobacion: true,
        requiereDocumento: false,
        color: '#6B7280',
        activo: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    final (IconData icono, Color color) = estiloTipoAusencia(tipo.nombre);
    return TramiteItem(
      id: a.id,
      titulo: tipo.nombre,
      icono: icono,
      color: color,
      inicio: a.fechaInicio,
      fin: a.fechaFin,
      dias: a.diasAusencia,
      estado: a.estado.name,
      esAusencia: true,
      abrir: (context) => context.push(
        '/tramites/ausencia/${a.id}',
        extra: <String, dynamic>{'ausencia': a, 'tipo': tipo},
      ),
    );
  }

  final String id;
  final String titulo;
  final IconData icono;
  final Color color;
  final DateTime inicio;
  final DateTime fin;
  final int dias;
  final String estado;
  final bool esAusencia;
  final void Function(BuildContext context) abrir;

  /// Icono y color según el nombre del tipo de ausencia
  static (IconData, Color) estiloTipoAusencia(String nombre) {
    final String n = nombre.toLowerCase();
    if (n.contains('médica') || n.contains('medica')) {
      return (Icons.local_hospital_outlined, AppColors.error);
    }
    if (n.contains('personal')) {
      return (Icons.person_outline_rounded, AppColors.secondary);
    }
    if (n.contains('formación') || n.contains('formacion')) {
      return (Icons.school_outlined, AppColors.primary);
    }
    if (n.contains('compensatorio')) {
      return (Icons.event_available_outlined, AppColors.info);
    }
    return (Icons.event_busy_outlined, AppColors.warning);
  }
}
