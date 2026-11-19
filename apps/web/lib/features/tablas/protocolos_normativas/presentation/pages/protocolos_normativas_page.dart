import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/data/repositories/protocolo_normativa_repository_impl.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/bloc/protocolo_normativa_bloc.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/bloc/protocolo_normativa_event.dart';
import 'package:ambutrack_web/features/tablas/protocolos_normativas/presentation/widgets/gestion/protocolo_normativa_gestion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página de gestión de protocolos y normativas (tabla maestra)
class ProtocolosNormativasPage extends StatelessWidget {
  const ProtocolosNormativasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<ProtocoloNormativaBloc>(
        create: (BuildContext _) => ProtocoloNormativaBloc(ProtocoloNormativaRepositoryImpl())
          ..add(const ProtocoloNormativaLoadAllRequested()),
        child: const Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ProtocoloNormativaGestionView(),
        ),
      ),
    );
  }
}
