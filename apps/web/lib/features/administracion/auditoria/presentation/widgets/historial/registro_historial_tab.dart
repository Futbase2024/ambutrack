import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/domain/repositories/audit_log_repository.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_helpers.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/historial/historial_registro_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Máximo de campos que se listan por cambio (el resto se resume)
const int _kMaxCampos = 6;

/// Pestaña "Historial" reutilizable para las fichas laterales.
///
/// Muestra quién cambió qué y cuándo (audit_log) para el registro
/// [registroId] de la tabla [tabla]. Solo devuelve datos a los roles que
/// gestionan ese módulo (ver `fn_historial_registro`).
class RegistroHistorialTab extends StatelessWidget {
  const RegistroHistorialTab({required this.tabla, required this.registroId, super.key});

  final String tabla;
  final String registroId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistorialRegistroCubit>(
      key: ValueKey<String>('$tabla/$registroId'),
      create: (BuildContext _) =>
          HistorialRegistroCubit(getIt<AuditLogRepository>(), tabla: tabla, registroId: registroId)..cargar(),
      child: const _HistorialContenido(),
    );
  }
}

class _HistorialContenido extends StatelessWidget {
  const _HistorialContenido();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistorialRegistroCubit, HistorialRegistroState>(
      builder: (BuildContext context, HistorialRegistroState state) {
        if (state.cargando) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state.error != null) {
          return const GestionDetailEmpty(message: 'No se pudo cargar el historial');
        }
        if (state.cambios.isEmpty) {
          return const GestionDetailEmpty(message: 'Sin cambios registrados para este registro');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
          itemCount: state.cambios.length,
          separatorBuilder: (BuildContext _, int __) => const Divider(height: 18, color: AppColors.gray200),
          itemBuilder: (BuildContext _, int i) => _CambioItem(cambio: state.cambios[i]),
        );
      },
    );
  }
}

/// Un cambio: cabecera (acción · fecha · usuario) y campos modificados
class _CambioItem extends StatelessWidget {
  const _CambioItem({required this.cambio});

  final AuditLogEntity cambio;

  @override
  Widget build(BuildContext context) {
    final List<AuditoriaCambio> campos = cambio.esModificacion ? auditoriaCambios(cambio) : <AuditoriaCambio>[];
    final int resto = campos.length - _kMaxCampos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            GestionDotLabel(
              label: auditoriaAccionLabel(cambio.accion),
              color: auditoriaAccionColor(cambio.accion),
              fontSize: 12,
            ),
            const Spacer(),
            Text(
              auditoriaFechaHora(cambio.createdAt),
              style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          auditoriaUsuarioLabel(cambio),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.gray700),
        ),
        for (final AuditoriaCambio c in campos.take(_kMaxCampos)) _CampoCambiado(cambio: c),
        if (resto > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ $resto campos más (ver en Administración › Auditoría)',
              style: const TextStyle(fontSize: 11.5, color: AppColors.gray500),
            ),
          ),
      ],
    );
  }
}

/// "campo: antes → después"
class _CampoCambiado extends StatelessWidget {
  const _CampoCambiado({required this.cambio});

  final AuditoriaCambio cambio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 12, color: AppColors.gray800, height: 1.35),
          children: <InlineSpan>[
            TextSpan(text: '${cambio.campo}: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(
              text: cambio.antes,
              style: const TextStyle(color: AppColors.gray500, decoration: TextDecoration.lineThrough),
            ),
            const TextSpan(text: '  →  '),
            TextSpan(text: cambio.despues),
          ],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
