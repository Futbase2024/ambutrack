import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_bloc.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/bloc/auditoria_event.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/auditoria_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Auditorías y Logs: visor (solo lectura) de la tabla `audit_log`.
///
/// Muestra quién cambió qué y cuándo en las tablas clave (usuarios, personal,
/// vehículos, traslados, servicios, contratos, taller, ITV y empresas).
class AuditoriasLogsPage extends StatelessWidget {
  const AuditoriasLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<AuditoriaBloc>(
        create: (BuildContext _) => getIt<AuditoriaBloc>()..add(const AuditoriaLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: AuditoriaGestionView(),
        ),
      ),
    );
  }
}
