import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/loading/app_skeleton.dart';

/// Lista de tipos de ausencia seleccionable (sustituye al desplegable)
class TipoAusenciaSelector extends StatelessWidget {
  const TipoAusenciaSelector({
    super.key,
    required this.tipos,
    required this.seleccionado,
    required this.onChanged,
    this.cargando = false,
    this.enabled = true,
  });

  final List<TipoAusenciaEntity> tipos;
  final TipoAusenciaEntity? seleccionado;
  final ValueChanged<TipoAusenciaEntity> onChanged;
  final bool cargando;
  final bool enabled;

  /// Busca el tipo que corresponde a una clave como 'baja_medica' o 'permiso_personal'
  static TipoAusenciaEntity? buscarPorClave(List<TipoAusenciaEntity> tipos, String? clave) {
    if (clave == null || clave.isEmpty) {
      return null;
    }
    final List<String> palabras = clave.split('_');
    for (final TipoAusenciaEntity tipo in tipos) {
      final String nombre = _normalizar(tipo.nombre);
      if (palabras.every(nombre.contains)) {
        return tipo;
      }
    }
    for (final TipoAusenciaEntity tipo in tipos) {
      if (_normalizar(tipo.nombre).contains(palabras.first)) {
        return tipo;
      }
    }
    return null;
  }

  static String _normalizar(String texto) {
    const Map<String, String> acentos = <String, String>{'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u'};
    String resultado = texto.toLowerCase();
    acentos.forEach((String con, String sin) => resultado = resultado.replaceAll(con, sin));
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    if (tipos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: cargando
            ? const Column(
                children: <Widget>[
                  AppSkeleton(height: 18),
                  SizedBox(height: 14),
                  AppSkeleton(height: 18),
                  SizedBox(height: 14),
                  AppSkeleton(width: 180, height: 18),
                ],
              )
            : const Text(
                'No hay tipos de ausencia disponibles',
                style: TextStyle(fontSize: 14, color: AppColors.gray500),
              ),
      );
    }

    return Column(
      children: <Widget>[
        for (int i = 0; i < tipos.length; i++) ...<Widget>[
          if (i > 0) const Divider(height: 1, indent: 48, color: AppColors.gray100),
          _TipoFila(
            tipo: tipos[i],
            seleccionado: tipos[i].id == seleccionado?.id,
            onTap: enabled ? () => onChanged(tipos[i]) : null,
          ),
        ],
      ],
    );
  }
}

/// Fila de un tipo de ausencia
class _TipoFila extends StatelessWidget {
  const _TipoFila({required this.tipo, required this.seleccionado, required this.onTap});

  final TipoAusenciaEntity tipo;
  final bool seleccionado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String? descripcion = tipo.descripcion;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: seleccionado ? AppColors.primarySurface : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                seleccionado ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: seleccionado ? AppColors.primary : AppColors.gray400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        tipo.nombre,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: seleccionado ? FontWeight.w600 : FontWeight.w500,
                          color: AppColors.gray900,
                        ),
                      ),
                      if (tipo.requiereDocumento) const _EtiquetaJustificante(),
                    ],
                  ),
                  if (descripcion != null && descripcion.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(descripcion, style: const TextStyle(fontSize: 13, color: AppColors.gray500, height: 1.3)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Etiqueta de tipo que requiere justificante
class _EtiquetaJustificante extends StatelessWidget {
  const _EtiquetaJustificante();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Requiere justificante',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mediumPriority),
      ),
    );
  }
}
