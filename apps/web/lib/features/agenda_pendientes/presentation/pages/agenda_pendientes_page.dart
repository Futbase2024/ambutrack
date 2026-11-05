import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_bloc.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_event.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_state.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/agenda_pendiente_form_dialog.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/agenda_pendientes_table.dart';
import 'package:ambutrack_web/features/auth/data/mappers/user_mapper.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart'
    as app_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Página de Agenda de Pendientes
///
/// Muestra los servicios pendientes que aún no han sido grabados,
/// con opciones de CRUD y filtrado por búsqueda.
class AgendaPendientesPage extends StatelessWidget {
  const AgendaPendientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AgendaPendienteBloc>(
      create: (BuildContext context) => getIt<AgendaPendienteBloc>()
        ..add(AgendaPendienteLoadRequested(
          empresaId: _getEmpresaId(context),
        )),
      child: const _AgendaPendientesView(),
    );
  }

  static String _getEmpresaId(BuildContext context) {
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

class _AgendaPendientesView extends StatefulWidget {
  const _AgendaPendientesView();

  @override
  State<_AgendaPendientesView> createState() => _AgendaPendientesViewState();
}

class _AgendaPendientesViewState extends State<_AgendaPendientesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.gray50,
        body: BlocConsumer<AgendaPendienteBloc, AgendaPendienteState>(
          listener: _onStateChange,
          builder: (BuildContext context, AgendaPendienteState state) {
            return Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context, state),
                  const SizedBox(height: AppSizes.spacing),
                  Expanded(child: _buildBody(context, state)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onStateChange(BuildContext context, AgendaPendienteState state) {
    if (state is AgendaPendienteLoaded && state.message != null) {
      final bool isError = state.message!.startsWith('Error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message!),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context, AgendaPendienteState state) {
    final AgendaPendienteLoaded? loaded =
        state is AgendaPendienteLoaded ? state : null;

    return PageHeader(
      config: PageHeaderConfig(
        title: 'Agenda de Pendientes',
        subtitle: 'Servicios pendientes de anotar que aún no han sido grabados',
        icon: Icons.event_note,
        addButtonLabel: 'Nuevo Pendiente',
        onAdd: () => _showFormDialog(context),
        stats: <HeaderStat>[
          HeaderStat(
            value: '${loaded?.pendientes.length ?? 0}',
            icon: Icons.list_alt,
          ),
          HeaderStat(
            value: '${loaded?.totalPendientes ?? 0}',
            icon: Icons.pending_actions,
            color: AppColors.warning,
          ),
          HeaderStat(
            value: '${loaded?.totalCompletados ?? 0}',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ],
        extra: _SearchAndBadgeRow(
          controller: _searchController,
          onSearch: (String q) => context
              .read<AgendaPendienteBloc>()
              .add(AgendaPendienteSearchChanged(query: q)),
          hoyCount: loaded?.pendientesHoy.length ?? 0,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AgendaPendienteState state) {
    if (state is AgendaPendienteLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is AgendaPendienteError) {
      return _ErrorView(message: state.message, onRetry: () => _reload(context));
    }

    if (state is AgendaPendienteLoaded) {
      if (state.pendientes.isEmpty) {
        return _EmptyView(onAdd: () => _showFormDialog(context));
      }
      return AgendaPendientesTable(
        pendientes: state.filteredPendientes,
        empresaId: _empresaId(context),
      );
    }

    return const SizedBox.shrink();
  }

  String _empresaId(BuildContext context) {
    final app_auth.AuthState authState = context.read<AuthBloc>().state;
    if (authState is app_auth.AuthAuthenticated) {
      return authState.user.empresaId ??
          '00000000-0000-0000-0000-000000000001';
    }
    return '00000000-0000-0000-0000-000000000001';
  }

  void _reload(BuildContext context) {
    context.read<AgendaPendienteBloc>().add(
          AgendaPendienteLoadRequested(empresaId: _empresaId(context)),
        );
  }

  void _showFormDialog(BuildContext context) {
    showAgendaPendienteFormDialog(
      context: context,
      empresaId: _empresaId(context),
    );
  }
}

/// Fila de búsqueda + badge de pendientes hoy
class _SearchAndBadgeRow extends StatelessWidget {
  const _SearchAndBadgeRow({
    required this.controller,
    required this.onSearch,
    required this.hoyCount,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final int hoyCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Badge pendientes hoy
        if (hoyCount > 0) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.today, size: 16, color: AppColors.warning),
                const SizedBox(width: 6),
                Text(
                  '$hoyCount pendiente${hoyCount == 1 ? '' : 's'} hoy',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.spacingSmall),
        ],
        // Campo de búsqueda
        SizedBox(
          width: 280,
          child: TextField(
            controller: controller,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, localidad...',
              hintStyle: GoogleFonts.inter(fontSize: 13),
              prefixIcon:
                  const Icon(Icons.search, size: 18, color: AppColors.gray400),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.gray300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.gray300),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Vista de estado vacío
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_outlined,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay pendientes registrados',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega un nuevo pendiente para empezar a gestionar\nservicios que aún no han sido grabados.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.gray600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nuevo Pendiente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.gray700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
