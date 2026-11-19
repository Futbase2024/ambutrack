import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../../di/injection.dart';
import 'cambio_clave_obligatorio_view.dart';

/// Capa sobre toda la app: si el usuario entra con una clave provisional
/// (alta o restablecimiento desde la web), le obliga a elegir su PIN antes de seguir.
///
/// Va en `MaterialApp.router(builder: ...)`, por encima del Navigator, así que
/// la vista lleva su propio Navigator (Overlay para el teclado).
class CambioClaveObligatorioGate extends StatefulWidget {
  const CambioClaveObligatorioGate({required this.child, super.key});

  final Widget child;

  @override
  State<CambioClaveObligatorioGate> createState() => _CambioClaveObligatorioGateState();
}

class _CambioClaveObligatorioGateState extends State<CambioClaveObligatorioGate> {
  final AuthRepository _auth = getIt<AuthRepository>();
  bool _debeCambiar = false;

  /// Usuario ya comprobado (evita repetir la consulta en cada emisión del BLoC)
  String? _uidComprobado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _sincronizar(context.read<AuthBloc>().state);
      }
    });
  }

  Future<void> _sincronizar(AuthState state) async {
    if (state is AuthAuthenticated) {
      final String uid = state.user.id;
      if (uid == _uidComprobado) {
        return;
      }
      _uidComprobado = uid;
      try {
        final bool debe = await _auth.debeCambiarClave();
        if (mounted) {
          setState(() => _debeCambiar = debe);
        }
      } catch (e) {
        debugPrint('⚠️ [CambioClaveGate] No se pudo comprobar la clave provisional: $e');
      }
    } else if (state is AuthUnauthenticated) {
      _uidComprobado = null;
      if (_debeCambiar) {
        setState(() => _debeCambiar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext _, AuthState state) => _sincronizar(state),
      child: Stack(
        children: <Widget>[
          widget.child,
          if (_debeCambiar)
            Positioned.fill(
              child: Navigator(
                onGenerateRoute: (_) => MaterialPageRoute<void>(
                  builder: (_) => CambioClaveObligatorioView(
                    onCambiada: () => setState(() => _debeCambiar = false),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
