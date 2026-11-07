import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/di/locator.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_bloc.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_event.dart';
import 'package:ambutrack_web/features/personal/presentation/bloc/formacion/formacion_state.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/common/personal_gestion_common.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_catalogos.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/formacion/formacion_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_related_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pestaña "Formación" de la ficha del empleado.
///
/// La formación se registra contra el id de usuario del empleado.
class PersonalFormacionTab extends StatefulWidget {
  const PersonalFormacionTab({required this.personalId, super.key});

  /// Id con el que se registra la formación (usuario vinculado del empleado)
  final String personalId;

  @override
  State<PersonalFormacionTab> createState() => _PersonalFormacionTabState();
}

class _PersonalFormacionTabState extends State<PersonalFormacionTab> {
  /// Catálogos compartidos entre fichas durante la sesión
  static Future<FormacionCatalogos>? _catalogosFuture;
  FormacionCatalogos _catalogos = const FormacionCatalogos();

  @override
  void initState() {
    super.initState();
    _catalogosFuture ??= FormacionCatalogos.load();
    _catalogosFuture!.then((FormacionCatalogos c) {
      if (c.certificaciones.isEmpty && c.cursos.isEmpty) {
        _catalogosFuture = null;
      }
      if (mounted) {
        setState(() => _catalogos = c);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FormacionBloc>(
      create: (BuildContext _) =>
          getIt<FormacionBloc>()..add(FormacionLoadByPersonalRequested(widget.personalId)),
      child: BlocBuilder<FormacionBloc, FormacionState>(
        builder: (BuildContext context, FormacionState state) {
          if (state is FormacionError) {
            return GestionDetailBody(children: <Widget>[GestionDetailMessage(state.message)]);
          }
          if (state is! FormacionLoaded) {
            return const GestionDetailLoading();
          }
          return _FormacionList(items: state.items, catalogos: _catalogos);
        },
      ),
    );
  }
}

class _FormacionList extends StatelessWidget {
  const _FormacionList({required this.items, required this.catalogos});

  final List<FormacionPersonalEntity> items;
  final FormacionCatalogos catalogos;

  @override
  Widget build(BuildContext context) {
    final List<FormacionPersonalEntity> sorted = List<FormacionPersonalEntity>.of(items)
      ..sort((FormacionPersonalEntity a, FormacionPersonalEntity b) =>
          a.fechaExpiracion.compareTo(b.fechaExpiracion));
    int count(String estado) => items.where((FormacionPersonalEntity f) => f.estado == estado).length;
    final int horas = items.fold<int>(0, (int sum, FormacionPersonalEntity f) => sum + f.horasAcumuladas);
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Resumen'),
        GestionDetailField(label: 'Vigentes', value: '${count(FormacionEstado.vigente)}'),
        GestionDetailField(label: 'Próx. a vencer', value: '${count(FormacionEstado.proximaVencer)}'),
        GestionDetailField(label: 'Vencidas', value: '${count(FormacionEstado.vencida)}'),
        GestionDetailField(label: 'Horas totales', value: '$horas h'),
        const GestionDetailSection(title: 'Formación (por expiración)'),
        if (sorted.isEmpty)
          const GestionDetailMessage('Este empleado no tiene formación registrada')
        else
          ...sorted.map(
            (FormacionPersonalEntity f) => PersonalMiniRow(
              title: catalogos.formacion(f),
              dotLabel: formacionEstadoLabel(f.estado),
              dotColor: formacionEstadoColor(f.estado),
              date: f.fechaExpiracion,
            ),
          ),
      ],
    );
  }
}
