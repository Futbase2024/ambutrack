import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_helpers.dart';
import 'package:flutter/material.dart';

/// Pestaña "Cambios": tabla Campo | Antes | Después
class AuditoriaCambiosTab extends StatelessWidget {
  const AuditoriaCambiosTab({required this.registro, super.key});

  final AuditLogEntity registro;

  @override
  Widget build(BuildContext context) {
    final List<AuditoriaCambio> cambios = auditoriaCambios(registro);
    if (cambios.isEmpty) {
      return const GestionDetailEmpty(message: 'El registro de auditoría no contiene datos');
    }
    final String nota = registro.esModificacion
        ? 'Campos modificados en esta operación'
        : registro.esAlta
            ? 'Valores con los que se dio de alta el registro'
            : 'Valores que tenía el registro al darse de baja';
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(nota, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
        ),
        const _CambioHeader(),
        for (int i = 0; i < cambios.length; i++) _CambioRow(cambio: cambios[i], par: i.isEven),
      ],
    );
  }
}

class _CambioHeader extends StatelessWidget {
  const _CambioHeader();

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.gray600);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        border: Border(bottom: BorderSide(color: AppColors.gray300)),
      ),
      child: const Row(
        children: <Widget>[
          Expanded(flex: 3, child: Text('Campo', style: style)),
          Expanded(flex: 4, child: Text('Antes', style: style)),
          Expanded(flex: 4, child: Text('Después', style: style)),
        ],
      ),
    );
  }
}

class _CambioRow extends StatelessWidget {
  const _CambioRow({required this.cambio, required this.par});

  final AuditoriaCambio cambio;
  final bool par;

  @override
  Widget build(BuildContext context) {
    final Color fondo = cambio.cambiado
        ? AppColors.warning.withValues(alpha: 0.06)
        : (par ? Colors.white : AppColors.gray50);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: fondo,
        border: const Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              cambio.campo,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray700),
            ),
          ),
          Expanded(
            flex: 4,
            child: _ValorCell(texto: cambio.antes, color: cambio.cambiado ? AppColors.error : null),
          ),
          Expanded(
            flex: 4,
            child: _ValorCell(texto: cambio.despues, color: cambio.cambiado ? AppColors.success : null),
          ),
        ],
      ),
    );
  }
}

class _ValorCell extends StatelessWidget {
  const _ValorCell({required this.texto, this.color});

  final String texto;

  /// Color de resaltado (rojo = valor anterior, verde = valor nuevo)
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bool vacio = texto == GestionFormatters.vacio;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: SelectableText(
        texto,
        maxLines: 4,
        style: TextStyle(
          fontSize: 12,
          fontWeight: color != null && !vacio ? FontWeight.w600 : FontWeight.w400,
          color: vacio ? AppColors.gray300 : (color ?? AppColors.gray900),
        ),
      ),
    );
  }
}
