import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:ambutrack_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Ruta `/logout`: cierra la sesión mediante [AuthBloc] y redirige a `/login`
class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  void initState() {
    super.initState();
    final AuthBloc authBloc = context.read<AuthBloc>();
    if (authBloc.state is AuthUnauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _irALogin());
    } else {
      authBloc.add(const AuthLogoutRequested());
    }
  }

  void _irALogin() {
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (AuthState _, AuthState current) =>
          current is AuthUnauthenticated || current is AuthError,
      listener: (BuildContext _, AuthState _) => _irALogin(),
      child: const SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(strokeWidth: 2),
                SizedBox(height: 16),
                Text('Cerrando sesión...', style: TextStyle(fontSize: 14, color: AppColors.gray600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
