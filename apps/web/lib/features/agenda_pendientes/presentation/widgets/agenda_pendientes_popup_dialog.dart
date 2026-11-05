import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Storage helper – persiste los IDs de pendientes vistos por día
// ---------------------------------------------------------------------------

/// Clave base para SharedPreferences: `agenda_vistos_{userId}_{YYYY-MM-DD}`
const String _prefsKeyPrefix = 'agenda_vistos_';

/// Devuelve los IDs de pendientes que el usuario ya ha marcado como vistos hoy.
Future<Set<String>> getPendientesVistosHoy(String userId) async {
  final String key = _buildKey(userId);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String>? ids = prefs.getStringList(key);
  return ids?.toSet() ?? <String>{};
}

/// Marca un pendiente como visto para hoy.
Future<void> marcarPendienteVisto(String userId, String pendienteId) async {
  final String key = _buildKey(userId);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Set<String> vistos = (prefs.getStringList(key)?.toSet() ?? <String>{})
    ..add(pendienteId);
  await prefs.setStringList(key, vistos.toList());
}

/// Marca todos los pendientes como vistos para hoy.
Future<void> marcarTodosVistos(String userId, List<String> ids) async {
  final String key = _buildKey(userId);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Set<String> vistos = (prefs.getStringList(key)?.toSet() ?? <String>{})
    ..addAll(ids);
  await prefs.setStringList(key, vistos.toList());
}

String _buildKey(String userId) {
  final String today = DateTime.now().toIso8601String().split('T')[0];
  return '$_prefsKeyPrefix${userId}_$today';
}

// ---------------------------------------------------------------------------
// Diálogo público
// ---------------------------------------------------------------------------

/// Muestra un diálogo popup con los pendientes de hoy sin completar
/// que aún no han sido marcados como vistos por el usuario.
///
/// Filtra automáticamente los ya vistos hoy. Si no quedan pendientes por
/// ver, no abre el diálogo y devuelve `false`.
Future<bool> showAgendaPendientesPopupDialog({
  required BuildContext context,
  required List<AgendaPendienteEntity> pendientes,
  required String userId,
}) async {
  // Filtrar los que ya fueron vistos hoy
  final Set<String> vistos = await getPendientesVistosHoy(userId);
  final List<AgendaPendienteEntity> noVistos = pendientes
      .where((AgendaPendienteEntity p) => !vistos.contains(p.id))
      .toList();

  if (noVistos.isEmpty || !context.mounted) {
    return false;
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) => _AgendaPendientesPopupContent(
      pendientes: noVistos,
      userId: userId,
    ),
  );
  return true;
}

// ---------------------------------------------------------------------------
// Contenido del diálogo (StatefulWidget para gestionar la lista)
// ---------------------------------------------------------------------------

class _AgendaPendientesPopupContent extends StatefulWidget {
  const _AgendaPendientesPopupContent({
    required this.pendientes,
    required this.userId,
  });

  final List<AgendaPendienteEntity> pendientes;
  final String userId;

  @override
  State<_AgendaPendientesPopupContent> createState() =>
      _AgendaPendientesPopupContentState();
}

class _AgendaPendientesPopupContentState
    extends State<_AgendaPendientesPopupContent> {
  late List<AgendaPendienteEntity> _pendientes;

  @override
  void initState() {
    super.initState();
    _pendientes = List<AgendaPendienteEntity>.from(widget.pendientes);
  }

  Future<void> _marcarVisto(AgendaPendienteEntity pendiente) async {
    await marcarPendienteVisto(widget.userId, pendiente.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _pendientes.removeWhere(
        (AgendaPendienteEntity p) => p.id == pendiente.id,
      );
    });
    if (_pendientes.isEmpty && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _marcarTodoVisto() async {
    await marcarTodosVistos(
      widget.userId,
      _pendientes.map((AgendaPendienteEntity p) => p.id).toList(),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _PendientesHeader(cantidad: _pendientes.length),
            const Divider(height: 1, color: AppColors.gray200),
            Flexible(
              child: _PendientesLista(
                pendientes: _pendientes,
                onVisto: _marcarVisto,
              ),
            ),
            if (_pendientes.isNotEmpty) ...<Widget>[
              const Divider(height: 1, color: AppColors.gray200),
              _PendientesFooter(
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

class _PendientesHeader extends StatelessWidget {
  const _PendientesHeader({required this.cantidad});

  final int cantidad;

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
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_outlined,
              size: AppSizes.iconLarge,
              color: AppColors.warning,
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
                      ? '1 pendiente en agenda'
                      : '$cantidad pendientes en agenda',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.fontMedium,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tienes tareas pendientes próximas',
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

class _PendientesLista extends StatelessWidget {
  const _PendientesLista({
    required this.pendientes,
    required this.onVisto,
  });

  final List<AgendaPendienteEntity> pendientes;
  final void Function(AgendaPendienteEntity) onVisto;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppSizes.padding),
      itemCount: pendientes.length,
      itemBuilder: (BuildContext context, int index) {
        final AgendaPendienteEntity pendiente = pendientes[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < pendientes.length - 1 ? AppSizes.spacing : 0,
          ),
          child: _PendienteCard(
            key: ValueKey<String>(pendiente.id),
            pendiente: pendiente,
            onVisto: () => onVisto(pendiente),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tarjeta individual con botón Visto
// ---------------------------------------------------------------------------

class _PendienteCard extends StatelessWidget {
  const _PendienteCard({
    required this.pendiente,
    required this.onVisto,
    super.key,
  });

  final AgendaPendienteEntity pendiente;
  final VoidCallback onVisto;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusMedium),
                  bottomLeft: Radius.circular(AppSizes.radiusMedium),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(AppSizes.spacingSmall),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: AppSizes.iconMedium,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacingSmall),
                        Flexible(
                          child: Text(
                            pendiente.nombreApellidos.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.fontXs,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    Text(
                      pendiente.descripcion,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (pendiente.domicilio != null &&
                        pendiente.domicilio!.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _formatLocation(pendiente),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.gray600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSizes.spacing),
                    TextButton(
                      onPressed: onVisto,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingSmall,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusSmall),
                          side: BorderSide(
                            color:
                                AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.check_circle_outline, size: 15),
                          const SizedBox(width: AppSizes.spacingXs),
                          Text(
                            'Visto',
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.fontXs,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLocation(AgendaPendienteEntity p) {
    final List<String> parts = <String>[
      if (p.domicilio != null && p.domicilio!.isNotEmpty) p.domicilio!,
      if (p.localidad != null && p.localidad!.isNotEmpty) p.localidad!,
    ];
    return parts.join(', ');
  }
}

// ---------------------------------------------------------------------------
// Footer con Cerrar + Marcar todo visto
// ---------------------------------------------------------------------------

class _PendientesFooter extends StatelessWidget {
  const _PendientesFooter({required this.onMarcarTodoVisto});

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
