import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_bloc.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/bloc/agenda_pendiente_event.dart';
import 'package:ambutrack_web/features/agenda_pendientes/presentation/widgets/gestion/agenda_gestion_view.dart';
import 'package:ambutrack_web/features/auth/data/mappers/user_mapper.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart' as app_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Página de Agenda de Pendientes (layout tipo programa de gestión)
///
/// Servicios pendientes de anotar que aún no han sido grabados.
class AgendaPendientesPage extends StatelessWidget {
  const AgendaPendientesPage({super.key});

  static const String _empresaPorDefecto = '00000000-0000-0000-0000-000000000001';

  @override
  Widget build(BuildContext context) {
    final String empresaId = _getEmpresaId(context);
    return SafeArea(
      child: BlocProvider<AgendaPendienteBloc>(
        create: (BuildContext _) =>
            getIt<AgendaPendienteBloc>()..add(AgendaPendienteLoadRequested(empresaId: empresaId)),
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: AgendaGestionView(empresaId: empresaId),
        ),
      ),
    );
  }

  static String _getEmpresaId(BuildContext context) {
    final app_auth.AuthState authState = context.read<AuthBloc>().state;
    if (authState is app_auth.AuthAuthenticated) {
      return authState.user.empresaId ?? _empresaPorDefecto;
    }
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      return UserMapper.fromSupabaseUser(currentUser).empresaId ?? _empresaPorDefecto;
    }
    return _empresaPorDefecto;
  }
}
