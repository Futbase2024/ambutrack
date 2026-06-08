import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/headers/page_header.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/curso_catalogo/curso_catalogo_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/curso_catalogo/curso_catalogo_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/curso_catalogo_table.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/curso_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CursosCatalogoPage extends StatelessWidget {
  const CursosCatalogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<CursoCatalogoBloc>(
        create: (BuildContext _) => getIt<CursoCatalogoBloc>()
          ..add(const CursoCatalogoLoadRequested()),
        child: const _CursosCatalogoContent(),
      ),
    );
  }
}

class _CursosCatalogoContent extends StatefulWidget {
  const _CursosCatalogoContent();

  @override
  State<_CursosCatalogoContent> createState() => _CursosCatalogoContentState();
}

class _CursosCatalogoContentState extends State<_CursosCatalogoContent> {
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
                icon: Icons.menu_book,
                title: 'Catálogo de Cursos',
                subtitle: 'Gestiona los cursos del catálogo',
                stats: const <HeaderStat>[],
                onAdd: () => _showCreateDialog(context),
                addButtonLabel: 'Nuevo',
                extra: SizedBox(
                  width: 250,
                  child: CursoCatalogoSearchField(
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
              child: CursoCatalogoTable(searchQuery: _searchQuery),
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
        return const CursoFormDialog();
      },
    );
    if (result == true && context.mounted) {
      context.read<CursoCatalogoBloc>().add(const CursoCatalogoLoadRequested());
    }
  }
}
