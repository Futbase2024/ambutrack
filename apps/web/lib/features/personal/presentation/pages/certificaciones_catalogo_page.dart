import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/certificacion_catalogo/certificacion_catalogo_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/certificacion_catalogo/certificacion_catalogo_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/certificacion_catalogo_table.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/certificacion_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CertificacionesCatalogoPage extends StatelessWidget {
  const CertificacionesCatalogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CertificacionCatalogoBloc>(
        create: (BuildContext _) => getIt<CertificacionCatalogoBloc>()
          ..add(const CertificacionCatalogoLoadRequested()),
        child: const _CertificacionesCatalogoContent(),
      ),
    );
  }
}

class _CertificacionesCatalogoContent extends StatefulWidget {
  const _CertificacionesCatalogoContent();

  @override
  State<_CertificacionesCatalogoContent> createState() => _CertificacionesCatalogoContentState();
}

class _CertificacionesCatalogoContentState extends State<_CertificacionesCatalogoContent> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PageHeader(
              config: PageHeaderConfig(
                icon: Icons.verified,
                title: 'Catálogo de Certificaciones',
                subtitle: 'Gestiona las certificaciones del catálogo',
                stats: const <HeaderStat>[],
                onAdd: () => _showCreateDialog(context),
                addButtonLabel: 'Nueva',
                extra: SizedBox(
                  width: 250,
                  child: CertificacionCatalogoSearchField(
                    searchQuery: _searchQuery,
                    onSearchChanged: (String query) {
                      setState(() { _searchQuery = query; });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: CertificacionCatalogoTable(searchQuery: _searchQuery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const CertificacionFormDialog();
      },
    );
    if (result == true && context.mounted) {
      context.read<CertificacionCatalogoBloc>().add(const CertificacionCatalogoLoadRequested());
    }
  }
}
