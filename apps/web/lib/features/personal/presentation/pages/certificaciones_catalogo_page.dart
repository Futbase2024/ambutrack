import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/certificacion_catalogo/certificacion_catalogo_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/certificacion_catalogo/certificacion_catalogo_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/certificaciones/certificacion_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Catálogo de Certificaciones (layout tipo programa de gestión)
class CertificacionesCatalogoPage extends StatelessWidget {
  const CertificacionesCatalogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CertificacionCatalogoBloc>(
        create: (BuildContext _) =>
            getIt<CertificacionCatalogoBloc>()..add(const CertificacionCatalogoLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CertificacionGestionView(),
        ),
      ),
    );
  }
}
