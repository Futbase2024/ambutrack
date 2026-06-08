import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/certificacion_repository.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/curso_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_event.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/formacion_header.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/formacion_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormacionPage extends StatelessWidget {
  const FormacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<FormacionBloc>(
        create: (BuildContext _) => getIt<FormacionBloc>()..add(const FormacionLoadRequested()),
        child: const _FormacionPageContent(),
      ),
    );
  }
}

class _FormacionPageContent extends StatefulWidget {
  const _FormacionPageContent();

  @override
  State<_FormacionPageContent> createState() => _FormacionPageContentState();
}

class _FormacionPageContentState extends State<_FormacionPageContent> {
  final Map<String, String> _usuariosNombres = <String, String>{};
  final Map<String, String> _certificacionesNombres = <String, String>{};
  final Map<String, String> _cursosNombres = <String, String>{};

  String _searchQuery = '';
  String _filterEstado = 'todos';

  @override
  void initState() {
    super.initState();
    _loadCatalogos();
  }

  Future<void> _loadCatalogos() async {
    try {
      final List<Object?> results = await Future.wait(<Future<Object?>>[
        getIt<UsersDataSource>().getAll(),
        getIt<CertificacionRepository>().getAll(),
        getIt<CursoRepository>().getAll(),
      ]);

      if (mounted) {
        setState(() {
          if (results[0] is List<UserEntity>) {
            for (final UserEntity usuario in results[0] as List<UserEntity>) {
              _usuariosNombres[usuario.id] = usuario.displayName ?? usuario.email;
            }
          }
          if (results[1] is List<CertificacionEntity>) {
            for (final CertificacionEntity cert in results[1] as List<CertificacionEntity>) {
              _certificacionesNombres[cert.id] = '${cert.codigo} - ${cert.nombre}';
            }
          }
          if (results[2] is List<CursoEntity>) {
            for (final CursoEntity curso in results[2] as List<CursoEntity>) {
              _cursosNombres[curso.id] = curso.nombre;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error al cargar catálogos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FormacionHeader(
              usuariosNombres: _usuariosNombres,
              certificacionesNombres: _certificacionesNombres,
              cursosNombres: _cursosNombres,
              extra: _buildFilterBar(),
            ),
            const SizedBox(height: AppSizes.spacingXl),
            Expanded(
              child: FormacionTable(
                searchQuery: _searchQuery,
                filterEstado: _filterEstado,
                usuariosNombres: _usuariosNombres,
                certificacionesNombres: _certificacionesNombres,
                cursosNombres: _cursosNombres,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 250,
          child: FormacionSearchField(
            searchQuery: _searchQuery,
            onSearchChanged: (String query) {
              setState(() { _searchQuery = query; });
            },
          ),
        ),
        const SizedBox(width: AppSizes.spacing),
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<String>(
            initialValue: _filterEstado,
            decoration: InputDecoration(
              labelText: 'Estado',
              prefixIcon: const Icon(Icons.filter_list, size: 20, color: AppColors.textSecondaryLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.gray300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.gray300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              isDense: true,
            ),
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(value: 'todos', child: Text('Todos')),
              DropdownMenuItem<String>(value: 'vigente', child: Text('Vigentes')),
              DropdownMenuItem<String>(value: 'proxima_vencer', child: Text('Próximas a vencer')),
              DropdownMenuItem<String>(value: 'vencida', child: Text('Vencidas')),
            ],
            onChanged: (String? value) {
              if (value != null) {
                setState(() { _filterEstado = value; });
              }
            },
          ),
        ),
      ],
    );
  }
}
