import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_bloc.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_event.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_state.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/agenda_pendiente_form_dialog.dart';
import 'package:ambutrack_web/features/auth/data/mappers/user_mapper.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart'
    as app_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Card de Agenda de Pendientes para el dashboard
///
/// Sigue el patrón de diseño de las cards del dashboard
/// con Card, elevation, header con icono + título y lista
/// de pendientes programados para hoy.
class AgendaPendientesHoyBanner extends StatelessWidget {
  const AgendaPendientesHoyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final String empresaId = _getEmpresaId(context);

    return BlocProvider<AgendaPendienteBloc>(
      create: (BuildContext context) {
        return getIt<AgendaPendienteBloc>()
          ..add(AgendaPendienteLoadHoyRequested(empresaId: empresaId));
      },
      child: BlocBuilder<AgendaPendienteBloc, AgendaPendienteState>(
        builder: (BuildContext context, AgendaPendienteState state) {
          if (state is AgendaPendienteLoaded) {
            return Column(
              children: <Widget>[
                AgendaPendientesCard(
                  pendientes: state.pendientesHoy,
                  empresaId: empresaId,
                ),
                const SizedBox(height: 24),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _getEmpresaId(BuildContext context) {
    final app_auth.AuthState authState = context.read<AuthBloc>().state;
    if (authState is app_auth.AuthAuthenticated) {
      return authState.user.empresaId ??
          '00000000-0000-0000-0000-000000000001';
    }
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      return UserMapper.fromSupabaseUser(currentUser).empresaId ??
          '00000000-0000-0000-0000-000000000001';
    }
    return '00000000-0000-0000-0000-000000000001';
  }
}

/// Card con diseño consistente con las cards del dashboard
///
/// Usa el mismo patrón visual que las gráficas del dashboard:
/// - Card con elevation 2 y borderRadius 16
/// - Header con icono + título/subtítulo
/// - Contenido con lista de pendientes
class AgendaPendientesCard extends StatelessWidget {
  const AgendaPendientesCard({
    super.key,
    required this.pendientes,
    required this.empresaId,
  });

  final List<AgendaPendienteEntity> pendientes;
  final String empresaId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header (patrón ChartCard)
            _CardHeader(
              pendientesCount: pendientes.length,
              empresaId: empresaId,
            ),

            // Lista de pendientes
            if (pendientes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.gray200),
              const SizedBox(height: 8),
              ...pendientes.map((AgendaPendienteEntity p) {
                return _PendienteRow(pendiente: p);
              }),
            ] else ...<Widget>[
              const SizedBox(height: 16),
              _EmptyPendientes(),
            ],

            // Footer - Ver agenda completa
            const SizedBox(height: 8),
            _CardFooter(),
          ],
        ),
      ),
    );
  }
}

/// Header de la card con icono, título y acciones
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.pendientesCount,
    required this.empresaId,
  });

  final int pendientesCount;
  final String empresaId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.event_note,
            color: AppColors.info,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Agenda de Pendientes',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              Text(
                pendientesCount > 0
                    ? '$pendientesCount pendiente${pendientesCount == 1 ? '' : 's'} próximo${pendientesCount == 1 ? '' : 's'} (próx. 7 días)'
                    : 'Sin pendientes próximos',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
        // Badge con contador
        if (pendientesCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$pendientesCount',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
          ),
        const SizedBox(width: 8),
        // Botón Nuevo
        ElevatedButton.icon(
          onPressed: () {
            showAgendaPendienteFormDialog(
              context: context,
              empresaId: empresaId,
            );
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Nuevo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Fila individual de un pendiente
class _PendienteRow extends StatelessWidget {
  const _PendienteRow({required this.pendiente});

  final AgendaPendienteEntity pendiente;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          // Avatar con iniciales
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              _getInitials(pendiente.nombreApellidos),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.info,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nombre + localidad
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  pendiente.nombreApellidos,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (pendiente.localidad != null)
                  Text(
                    pendiente.localidad!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.gray500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Descripción
          Expanded(
            flex: 4,
            child: Tooltip(
              message: pendiente.descripcion,
              child: Text(
                pendiente.descripcion,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.gray600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final List<String> parts =
        name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}

/// Estado vacío cuando no hay pendientes para hoy
class _EmptyPendientes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle_outline,
              size: 18,
              color: AppColors.success.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'No hay pendientes próximos',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Footer con enlace a la agenda completa
class _CardFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () {
          context.go('/servicios/agenda-pendientes');
        },
        icon: const Icon(Icons.arrow_forward, size: 16),
        label: Text(
          'Ver Agenda Completa',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.info,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
