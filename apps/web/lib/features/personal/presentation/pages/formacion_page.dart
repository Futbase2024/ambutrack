import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Formación y Certificaciones del personal (layout tipo programa de gestión)
class FormacionPage extends StatelessWidget {
  const FormacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<FormacionBloc>(
        create: (BuildContext _) => getIt<FormacionBloc>()..add(const FormacionLoadRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: FormacionGestionView(),
        ),
      ),
    );
  }
}
