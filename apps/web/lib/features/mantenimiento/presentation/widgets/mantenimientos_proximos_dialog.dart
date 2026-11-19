import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/mantenimiento/presentation/widgets/mantenimiento_proximo_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Storage helper – persiste los IDs de mantenimientos vistos por día
// ---------------------------------------------------------------------------

/// Clave base para SharedPreferences: `mantenimiento_vistos_{userId}_{YYYY-MM-DD}`
const String _prefsKeyPrefix = 'mantenimiento_vistos_';

/// Devuelve los IDs de mantenimientos que el usuario ya ha marcado como vistos hoy.
Future<Set<String>> getMantenimientosVistosHoy(String userId) async {
  final String key = _buildKey(userId);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String>? ids = prefs.getStringList(key);
  return ids?.toSet() ?? <String>{};
}

/// Marca un mantenimiento como visto para hoy.
Future<void> marcarMantenimientoVisto(
    String userId, String mantenimientoId) async {
  final String key = _buildKey(userId);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    key,
    ((prefs.getStringList(key)?.toSet() ?? <String>{})..add(mantenimientoId))
        .toList(),
  );
}

/// Marca todos los mantenimientos indicados como vistos para hoy.
Future<void> marcarTodosMantenimientosVistos(
    String userId, List<String> ids) async {
  final String key = _buildKey(userId);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    key,
    ((prefs.getStringList(key)?.toSet() ?? <String>{})..addAll(ids)).toList(),
  );
}

String _buildKey(String userId) {
  final String today = DateTime.now().toIso8601String().split('T')[0];
  return '$_prefsKeyPrefix${userId}_$today';
}

// ---------------------------------------------------------------------------
// Helper de cálculo de días
// ---------------------------------------------------------------------------

/// Días restantes hasta la [MantenimientoEntity.fechaProgramada] (negativo si
/// está vencida). Devuelve 0 si no tiene fecha programada.
int diasRestantesMantenimiento(MantenimientoEntity m) {
  if (m.fechaProgramada == null) {
    return 0;
  }
  // Normalizar a local-midnight para evitar off-by-one cuando el DateTime
  // proviene de un `date` de Postgres (puede llegar como UTC).
  final DateTime raw = m.fechaProgramada!;
  final DateTime fechaLocal = raw.isUtc ? raw.toLocal() : raw;
  final DateTime fechaNormalizada =
      DateTime(fechaLocal.year, fechaLocal.month, fechaLocal.day);
  final DateTime ahora = DateTime.now();
  final DateTime hoy = DateTime(ahora.year, ahora.month, ahora.day);
  return fechaNormalizada.difference(hoy).inDays;
}

// ---------------------------------------------------------------------------
// Diálogo público
// ---------------------------------------------------------------------------

/// Muestra un diálogo con los mantenimientos **programados** que están
/// vencidos o a ≤7 días, filtrando los ya vistos hoy.
///
/// Si no quedan mantenimientos por ver, no abre el diálogo y devuelve `false`.
Future<bool> showMantenimientosProximosPopupDialog({
  required BuildContext context,
  required List<MantenimientoEntity> mantenimientos,
  required String userId,
}) async {
  final Set<String> vistos = await getMantenimientosVistosHoy(userId);
  final List<MantenimientoEntity> noVistos = mantenimientos
      .where((MantenimientoEntity m) => !vistos.contains(m.id))
      .toList();

  if (noVistos.isEmpty) {
    debugPrint(
      '🔧 MantenimientosProximos: popup omitido. '
      'recibidos=${mantenimientos.length}, vistosHoy=${vistos.length}, '
      'userId=$userId',
    );
    return false;
  }

  if (!context.mounted) {
    return false;
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => _MantenimientosProximosContent(
      mantenimientos: noVistos,
      userId: userId,
    ),
  );
  return true;
}

// ---------------------------------------------------------------------------
// Contenido del diálogo (StatefulWidget para gestionar la lista)
// ---------------------------------------------------------------------------

class _MantenimientosProximosContent extends StatefulWidget {
  const _MantenimientosProximosContent({
    required this.mantenimientos,
    required this.userId,
  });

  final List<MantenimientoEntity> mantenimientos;
  final String userId;

  @override
  State<_MantenimientosProximosContent> createState() =>
      _MantenimientosProximosContentState();
}

class _MantenimientosProximosContentState
    extends State<_MantenimientosProximosContent> {
  late List<MantenimientoEntity> _mantenimientos;

  @override
  void initState() {
    super.initState();
    _mantenimientos = List<MantenimientoEntity>.from(widget.mantenimientos);
  }

  Future<void> _marcarVisto(MantenimientoEntity mantenimiento) async {
    await marcarMantenimientoVisto(widget.userId, mantenimiento.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _mantenimientos.removeWhere(
          (MantenimientoEntity m) => m.id == mantenimiento.id);
    });
    if (_mantenimientos.isEmpty && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _marcarTodoVisto() async {
    await marcarTodosMantenimientosVistos(
      widget.userId,
      _mantenimientos.map((MantenimientoEntity m) => m.id).toList(),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  bool get _hayVencidos => _mantenimientos
      .any((MantenimientoEntity m) => diasRestantesMantenimiento(m) <= 0);

  @override
  Widget build(BuildContext context) {
    final Color colorPrincipal =
        _hayVencidos ? AppColors.emergency : AppColors.warning;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 560),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _MantenimientosProximosHeader(
              cantidad: _mantenimientos.length,
              hayVencidos: _hayVencidos,
              color: colorPrincipal,
            ),
            const Divider(height: 1, color: AppColors.gray200),
            Flexible(
              child: _MantenimientosProximosLista(
                mantenimientos: _mantenimientos,
                onVisto: _marcarVisto,
              ),
            ),
            if (_mantenimientos.isNotEmpty) ...<Widget>[
              const Divider(height: 1, color: AppColors.gray200),
              _MantenimientosProximosFooter(
                onMarcarTodoVisto: _marcarTodoVisto,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _MantenimientosProximosHeader extends StatelessWidget {
  const _MantenimientosProximosHeader({
    required this.cantidad,
    required this.hayVencidos,
    required this.color,
  });

  final int cantidad;
  final bool hayVencidos;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingXl,
        AppSizes.paddingXl,
        AppSizes.paddingXl,
        AppSizes.padding,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hayVencidos
                  ? Icons.report_problem_outlined
                  : Icons.build_circle_outlined,
              size: AppSizes.iconLarge,
              color: color,
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  cantidad == 1
                      ? '1 mantenimiento requiere atención'
                      : '$cantidad mantenimientos requieren atención',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMedium,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hayVencidos
                      ? 'Hay mantenimientos vencidos o que vencen pronto'
                      : 'Tienes mantenimientos programados próximos',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lista scrollable
// ---------------------------------------------------------------------------

class _MantenimientosProximosLista extends StatelessWidget {
  const _MantenimientosProximosLista({
    required this.mantenimientos,
    required this.onVisto,
  });

  final List<MantenimientoEntity> mantenimientos;
  final void Function(MantenimientoEntity) onVisto;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppSizes.padding),
      itemCount: mantenimientos.length,
      itemBuilder: (BuildContext context, int index) {
        final MantenimientoEntity mantenimiento = mantenimientos[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < mantenimientos.length - 1 ? AppSizes.spacing : 0,
          ),
          child: MantenimientoProximoCard(
            key: ValueKey<String>(mantenimiento.id),
            mantenimiento: mantenimiento,
            dias: diasRestantesMantenimiento(mantenimiento),
            onVisto: () => onVisto(mantenimiento),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Footer con Cerrar + Marcar todo visto
// ---------------------------------------------------------------------------

class _MantenimientosProximosFooter extends StatelessWidget {
  const _MantenimientosProximosFooter({required this.onMarcarTodoVisto});

  final VoidCallback onMarcarTodoVisto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingXl,
        AppSizes.padding,
        AppSizes.paddingXl,
        AppSizes.paddingXl,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gray700,
                side: const BorderSide(color: AppColors.gray300),
                padding:
                    const EdgeInsets.symmetric(vertical: AppSizes.padding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.close, size: AppSizes.iconMedium),
              label: Text(
                'Cerrar',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onMarcarTodoVisto,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSizes.padding),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.done_all, size: AppSizes.iconMedium),
              label: Text(
                'Marcar todo visto',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
