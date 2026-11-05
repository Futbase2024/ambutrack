import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichaje_ubicacion_tab.dart';
import 'package:ambutrack_web/features/personal/horarios/presentation/widgets/gestion/fichajes/fichajes_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del fichaje seleccionado
class FichajesDetailPanel extends StatelessWidget {
  const FichajesDetailPanel({required this.registro, required this.onMap, super.key});

  final RegistroHorarioEntity? registro;

  /// Abre el mapa ampliado del fichaje
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    final RegistroHorarioEntity? r = registro;
    if (r == null) {
      return const GestionDetailEmpty(message: 'Selecciona un fichaje para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(r.id),
      title: GestionFormatters.texto(r.nombrePersonal),
      badges: <Widget>[
        FichajeTipoDot(registro: r),
        GestionDotLabel(
          label: r.esManual ? 'Manual' : 'Automático',
          color: r.esManual ? AppColors.warning : AppColors.info,
        ),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _FichajeGeneralTab(registro: r)),
        GestionDetailTab(
          label: 'Ubicación',
          child: FichajeUbicacionTab(registro: r, onExpand: onMap),
        ),
      ],
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: onMap,
          icon: const Icon(Icons.map_outlined, size: 16),
          label: const Text('Ver mapa'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.info,
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _FichajeGeneralTab extends StatelessWidget {
  const _FichajeGeneralTab({required this.registro});

  final RegistroHorarioEntity registro;

  @override
  Widget build(BuildContext context) {
    final RegistroHorarioEntity r = registro;
    final double? horas = r.horasTrabajadas;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Fichaje'),
        GestionDetailField(label: 'Personal', value: r.nombrePersonal),
        GestionDetailField(label: 'Tipo', child: FichajeTipoDot(registro: r)),
        GestionDetailField(label: 'Fecha', value: GestionFormatters.fecha(r.fechaHora)),
        GestionDetailField(label: 'Hora', value: fichajeHora(r.fechaHora)),
        GestionDetailField(label: 'Estado', value: r.estado),
        GestionDetailField(label: 'Turno', value: r.turno),
        GestionDetailField(
          label: 'Horas trabajadas',
          value: horas == null ? null : '${horas.toStringAsFixed(2)} h',
        ),
        GestionDetailField(label: 'Registro manual', value: r.esManual ? 'Sí' : 'No'),
        const GestionDetailSection(title: 'Vehículo y ubicación'),
        GestionDetailField(label: 'Vehículo', value: r.vehiculoMatricula),
        GestionDetailField(label: 'Ubicación', value: r.ubicacion),
        GestionDetailField(label: 'Precisión GPS', child: FichajePrecisionDot(precision: r.precisionGps)),
        const GestionDetailSection(title: 'Notas'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            GestionFormatters.texto(r.notas),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: r.notas?.trim().isNotEmpty ?? false ? AppColors.gray800 : AppColors.gray300,
            ),
          ),
        ),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(r.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(r.updatedAt)),
      ],
    );
  }
}
