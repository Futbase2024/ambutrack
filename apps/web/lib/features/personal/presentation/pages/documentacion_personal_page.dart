import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/documento_personal_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/documento_personal_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/documentacion/documentacion_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de Documentación del Personal (layout tipo programa de gestión)
class DocumentacionPersonalPage extends StatelessWidget {
  const DocumentacionPersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<DocumentoPersonalBloc>(
        create: (BuildContext _) => getIt<DocumentoPersonalBloc>()..add(const DocumentoPersonalLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: DocumentacionGestionView(),
        ),
      ),
    );
  }
}
