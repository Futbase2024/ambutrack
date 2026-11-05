import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/curso_catalogo/curso_catalogo_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/curso_catalogo/curso_catalogo_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/cursos/curso_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Catálogo de Cursos (layout tipo programa de gestión)
class CursosCatalogoPage extends StatelessWidget {
  const CursosCatalogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CursoCatalogoBloc>(
        create: (BuildContext _) => getIt<CursoCatalogoBloc>()..add(const CursoCatalogoLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CursoGestionView(),
        ),
      ),
    );
  }
}
