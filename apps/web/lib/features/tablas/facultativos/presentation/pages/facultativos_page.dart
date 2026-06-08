import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_bloc.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/bloc/facultativo_event.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/facultativo_header.dart';
import 'package:ambutrack_web/features/tablas/facultativos/presentation/widgets/facultativo_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Página principal de facultativos
class FacultativosPage extends StatelessWidget {
  const FacultativosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<FacultativoBloc>(
        create: (BuildContext context) => getIt<FacultativoBloc>()
          ..add(const FacultativoLoadAllRequested()),
        child: const _FacultativosView(),
      ),
    );
  }
}

class _FacultativosView extends StatefulWidget {
  const _FacultativosView();

  @override
  State<_FacultativosView> createState() => _FacultativosViewState();
}

class _FacultativosViewState extends State<_FacultativosView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FacultativoHeader(
            extra: SizedBox(
              width: 250,
              child: FacultativoSearchField(
                searchQuery: _searchQuery,
                onSearchChanged: (String query) {
                  setState(() => _searchQuery = query);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          Expanded(
            child: FacultativoTable(searchQuery: _searchQuery),
          ),
        ],
      ),
    );
  }
}
