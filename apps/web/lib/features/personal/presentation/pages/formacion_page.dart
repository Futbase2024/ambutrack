import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/core/widgets/buttons/app_button.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/certificacion_repository.dart';
import 'package:ambutrack_web/features/personal/domain/repositories/curso_repository.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/formacion_details_dialog.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/formacion/formacion_personal_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Página de gestión de formación del personal
class FormacionPage extends StatelessWidget {
  const FormacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<FormacionBloc>(
        create: (BuildContext _) => getIt<FormacionBloc>()..add(const FormacionLoadRequested()),
        child: const _FormacionView(),
      ),
    );
  }
}

class _FormacionView extends StatefulWidget {
  const _FormacionView();

  @override
  State<_FormacionView> createState() => _FormacionViewState();
}

class _FormacionViewState extends State<_FormacionView> {
  final Map<String, String> _usuariosNombres = <String, String>{};
  final Map<String, String> _certificacionesNombres = <String, String>{};
  final Map<String, String> _cursosNombres = <String, String>{};

  @override
  void initState() {
    super.initState();
    _loadCatalogos();
  }

  Future<void> _loadCatalogos() async {
    try {
      // Cargar usuarios, certificaciones y cursos en paralelo
      final List<Object?> results = await Future.wait(<Future<Object?>>[
        getIt<UsersDataSource>().getAll(),
        getIt<CertificacionRepository>().getAll(),
        getIt<CursoRepository>().getAll(),
      ]);

      if (mounted) {
        setState(() {
          // Procesar usuarios
          if (results[0] is List<UserEntity>) {
            for (final UserEntity usuario in results[0] as List<UserEntity>) {
              _usuariosNombres[usuario.id] = usuario.displayName ?? usuario.email;
            }
          }

          // Procesar certificaciones
          if (results[1] is List<CertificacionEntity>) {
            for (final CertificacionEntity cert in results[1] as List<CertificacionEntity>) {
              _certificacionesNombres[cert.id] = '${cert.codigo} - ${cert.nombre}';
            }
          }

          // Procesar cursos
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
            // Header con stats integradas
            _FormacionHeader(
              usuariosNombres: _usuariosNombres,
              certificacionesNombres: _certificacionesNombres,
              cursosNombres: _cursosNombres,
            ),
            const SizedBox(height: AppSizes.spacingXl),

            // Búsqueda y filtros
            _buildSearchAndFilters(context),
            const SizedBox(height: AppSizes.spacingMedium),

            // Tabla de formación
            Expanded(
              child: _FormacionListWidget(
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

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o cargo...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.secondary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.backgroundLight,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Estado',
                prefixIcon: const Icon(Icons.filter_list, color: AppColors.textSecondaryLight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.backgroundLight,
              ),
              items: const <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(value: 'todos', child: Text('Todos')),
                DropdownMenuItem<String>(value: 'vigente', child: Text('Vigentes')),
                DropdownMenuItem<String>(value: 'proxima_vencer', child: Text('Próximas a vencer')),
                DropdownMenuItem<String>(value: 'vencida', child: Text('Vencidas')),
              ],
              onChanged: (String? value) {
                if (value != null) {
                  if (value == 'todos') {
                    context.read<FormacionBloc>().add(const FormacionLoadRequested());
                  } else if (value == 'vigente') {
                    context.read<FormacionBloc>().add(const FormacionLoadVigentesRequested());
                  } else if (value == 'proxima_vencer') {
                    context.read<FormacionBloc>().add(const FormacionLoadProximasVencerRequested());
                  } else if (value == 'vencida') {
                    context.read<FormacionBloc>().add(const FormacionLoadVencidasRequested());
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

}

/// Header de la página de formación con estadísticas integradas
class _FormacionHeader extends StatelessWidget {
  const _FormacionHeader({
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1024;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLarge,
        vertical: AppSizes.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: AppSizes.shadowMedium,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isDesktop
          ? _DesktopLayout(
              usuariosNombres: usuariosNombres,
              certificacionesNombres: certificacionesNombres,
              cursosNombres: cursosNombres,
            )
          : isTablet
              ? _TabletLayout(
                  usuariosNombres: usuariosNombres,
                  certificacionesNombres: certificacionesNombres,
                  cursosNombres: cursosNombres,
                )
              : _MobileLayout(
                  usuariosNombres: usuariosNombres,
                  certificacionesNombres: certificacionesNombres,
                  cursosNombres: cursosNombres,
                ),
    );
  }
}

/// Layout para desktop: Título | Stats | Botones (horizontal)
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const _TitleSection(),
        const SizedBox(width: AppSizes.spacingLarge),
        const Expanded(child: _StatsCards()),
        const SizedBox(width: AppSizes.spacingLarge),
        _ActionButtons(
          usuariosNombres: usuariosNombres,
          certificacionesNombres: certificacionesNombres,
          cursosNombres: cursosNombres,
        ),
      ],
    );
  }
}

/// Layout para tablet: Título + Botones arriba, Stats abajo
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(child: _TitleSection()),
            const SizedBox(width: AppSizes.spacing),
            _ActionButtons(
              usuariosNombres: usuariosNombres,
              certificacionesNombres: certificacionesNombres,
              cursosNombres: cursosNombres,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing),
        const _StatsCards(),
      ],
    );
  }
}

/// Layout para móvil: Todo en columna
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _TitleSection(),
        const SizedBox(height: AppSizes.spacing),
        const _StatsCards(),
        const SizedBox(height: AppSizes.spacing),
        _ActionButtons(
          usuariosNombres: usuariosNombres,
          certificacionesNombres: certificacionesNombres,
          cursosNombres: cursosNombres,
          isMobile: true,
        ),
      ],
    );
  }
}

/// Sección de título
class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          decoration: BoxDecoration(
            color: AppColors.formacion.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: const Icon(
            Icons.school,
            color: AppColors.formacion,
            size: AppSizes.iconMedium,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Formación y Certificaciones',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Gestiona la formación profesional de tu equipo',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontXs,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Cards de estadísticas
class _StatsCards extends StatelessWidget {
  const _StatsCards();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormacionBloc, FormacionState>(
      builder: (BuildContext context, FormacionState state) {
        String total = '-';
        String vigentes = '-';
        String proximas = '-';
        String vencidas = '-';

        if (state is FormacionLoaded) {
          final List<FormacionPersonalEntity> items = state.items;
          total = items.length.toString();
          vigentes = items.where((FormacionPersonalEntity f) => f.estado == 'vigente').length.toString();
          proximas = items.where((FormacionPersonalEntity f) => f.estado == 'proxima_vencer').length.toString();
          vencidas = items.where((FormacionPersonalEntity f) => f.estado == 'vencida').length.toString();
        }

        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 600;

        return isMobile
            ? Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _MiniStatCard(
                          value: total,
                          label: 'Total',
                          icon: Icons.school,
                          color: AppColors.formacion,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: vigentes,
                          label: 'Vigentes',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSmall),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _MiniStatCard(
                          value: proximas,
                          label: 'Próximas',
                          icon: Icons.warning,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingSmall),
                      Expanded(
                        child: _MiniStatCard(
                          value: vencidas,
                          label: 'Vencidas',
                          icon: Icons.error,
                          color: AppColors.emergency,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  Expanded(
                    child: _MiniStatCard(
                      value: total,
                      label: 'Total',
                      icon: Icons.school,
                      color: AppColors.formacion,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: vigentes,
                      label: 'Vigentes',
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: proximas,
                      label: 'Próximas',
                      icon: Icons.warning,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: _MiniStatCard(
                      value: vencidas,
                      label: 'Vencidas',
                      icon: Icons.error,
                      color: AppColors.emergency,
                    ),
                  ),
                ],
              );
      },
    );
  }
}

/// Botones de acción
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
    this.isMobile = false,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      // En móvil, mostrar botones apilados verticalmente
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () => _showFormacionDialog(context),
              icon: Icons.add,
              label: 'Asignar Formación',
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () => Navigator.of(context).pushNamed('/personal/formacion/certificaciones'),
              icon: Icons.verified,
              label: 'Certificaciones',
            ),
          ),
          const SizedBox(height: AppSizes.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () => Navigator.of(context).pushNamed('/personal/formacion/cursos'),
              icon: Icons.menu_book,
              label: 'Cursos',
            ),
          ),
        ],
      );
    }

    // Desktop/Tablet: mostrar botones horizontales
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppButton(
          onPressed: () => _showFormacionDialog(context),
          icon: Icons.add,
          label: 'Asignar Formación',
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        AppButton(
          onPressed: () => Navigator.of(context).pushNamed('/personal/formacion/certificaciones'),
          icon: Icons.verified,
          label: 'Certificaciones',
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        AppButton(
          onPressed: () => Navigator.of(context).pushNamed('/personal/formacion/cursos'),
          icon: Icons.menu_book,
          label: 'Cursos',
        ),
      ],
    );
  }

  Future<void> _showFormacionDialog(BuildContext context) async {
    final FormacionBloc bloc = context.read<FormacionBloc>();
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocProvider<FormacionBloc>.value(
          value: bloc,
          child: const FormacionPersonalFormDialog(),
        );
      },
    );
    if (result == true && context.mounted) {
      bloc.add(const FormacionLoadRequested());
    }
  }
}

/// Mini card de estadística para el header
class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSmall,
        vertical: AppSizes.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: AppSizes.iconLarge),
          const SizedBox(width: AppSizes.spacingXs),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMedium,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs,
                  color: color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget de lista de formación
class _FormacionListWidget extends StatelessWidget {
  const _FormacionListWidget({
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
  });

  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormacionBloc, FormacionState>(
      builder: (BuildContext context, FormacionState state) {
        if (state is FormacionLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is FormacionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar la formación',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is FormacionInitial) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is! FormacionLoaded) {
          return const SizedBox.shrink();
        }

        final List<FormacionPersonalEntity> items = state.items;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.school_outlined,
                  size: 80,
                  color: AppColors.gray400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No se encontró formación',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajusta los filtros para ver más resultados',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.gray900.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                _buildGridHeader(context),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _FormacionListItem(
                        formacion: items[index],
                        isEven: index % 2 == 0,
                        usuariosNombres: usuariosNombres,
                        certificacionesNombres: certificacionesNombres,
                        cursosNombres: cursosNombres,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: <Widget>[
          Expanded(flex: 3, child: _HeaderText('Personal')),
          Expanded(flex: 2, child: _HeaderText('Certificación/Curso')),
          Expanded(flex: 2, child: _HeaderText('Inicio')),
          Expanded(flex: 2, child: _HeaderText('Fin')),
          Expanded(flex: 2, child: _HeaderText('Expiración')),
          Expanded(child: _HeaderText('Horas')),
          Expanded(flex: 2, child: _HeaderText('Estado')),
          Expanded(child: _HeaderText('Acciones')),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
        letterSpacing: 0.3,
      ),
    );
  }
}

/// Item de la lista de formación
class _FormacionListItem extends StatelessWidget {
  const _FormacionListItem({
    required this.formacion,
    required this.isEven,
    required this.usuariosNombres,
    required this.certificacionesNombres,
    required this.cursosNombres,
  });

  final FormacionPersonalEntity formacion;
  final bool isEven;
  final Map<String, String> usuariosNombres;
  final Map<String, String> certificacionesNombres;
  final Map<String, String> cursosNombres;

  @override
  Widget build(BuildContext context) {
    final Color estadoColor = _getEstadoColor(formacion.estado);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : AppColors.backgroundLight.withValues(alpha: 0.3),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              usuariosNombres[formacion.personalId] ?? formacion.personalId,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _getFormacionNombre(),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd/MM/yyyy').format(formacion.fechaInicio),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd/MM/yyyy').format(formacion.fechaFin),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd/MM/yyyy').format(formacion.fechaExpiracion),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${formacion.horasAcumuladas}h',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: estadoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: estadoColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _getEstadoLabel(formacion.estado),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: estadoColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (String value) async {
                switch (value) {
                  case 'editar':
                    final bool? result = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return FormacionPersonalFormDialog(
                          item: formacion,
                        );
                      },
                    );
                    // Si se guardó correctamente, recargar la lista
                    if (result == true && context.mounted) {
                      context.read<FormacionBloc>().add(const FormacionLoadRequested());
                    }
                    break;
                  case 'ver':
                    // ignore: unawaited_futures
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return FormacionDetailsDialog(
                          formacion: formacion,
                          nombreEmpleado: usuariosNombres[formacion.personalId] ?? formacion.personalId,
                          nombreFormacion: _getFormacionNombre(),
                        );
                      },
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'ver',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.visibility, size: 18, color: AppColors.info),
                      SizedBox(width: 12),
                      Text('Ver Detalles'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'editar',
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.edit, size: 18, color: AppColors.secondaryLight),
                      SizedBox(width: 12),
                      Text('Editar'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'vigente':
        return AppColors.success;
      case 'proxima_vencer':
        return AppColors.warning;
      case 'vencida':
        return AppColors.emergency;
      default:
        return AppColors.gray600;
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'vigente':
        return 'Vigente';
      case 'proxima_vencer':
        return 'Próxima';
      case 'vencida':
        return 'Vencida';
      default:
        return estado;
    }
  }

  String _getFormacionNombre() {
    if (formacion.certificacionId != null) {
      return certificacionesNombres[formacion.certificacionId] ?? formacion.certificacionId ?? 'N/A';
    }
    if (formacion.cursoId != null) {
      return cursosNombres[formacion.cursoId] ?? formacion.cursoId ?? 'N/A';
    }
    return 'N/A';
  }
}
