import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/form/gestion_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos del formulario de formación personal
class FormacionPersonalFormBody extends StatelessWidget {
  const FormacionPersonalFormBody({
    required this.usuarios,
    required this.certificaciones,
    required this.cursos,
    required this.usuario,
    required this.certificacion,
    required this.curso,
    required this.fechaInicio,
    required this.fechaFin,
    required this.fechaExpiracion,
    required this.horas,
    required this.observaciones,
    required this.onUsuarioChanged,
    required this.onCertificacionChanged,
    required this.onCursoChanged,
    required this.onFechaInicioChanged,
    required this.onFechaFinChanged,
    required this.onFechaExpiracionChanged,
    super.key,
  });

  final List<UserEntity> usuarios;
  final List<CertificacionEntity> certificaciones;
  final List<CursoEntity> cursos;
  final UserEntity? usuario;
  final CertificacionEntity? certificacion;
  final CursoEntity? curso;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final DateTime? fechaExpiracion;
  final TextEditingController horas;
  final TextEditingController observaciones;
  final ValueChanged<String?> onUsuarioChanged;
  final ValueChanged<String?> onCertificacionChanged;
  final ValueChanged<String?> onCursoChanged;
  final ValueChanged<DateTime?> onFechaInicioChanged;
  final ValueChanged<DateTime?> onFechaFinChanged;
  final ValueChanged<DateTime?> onFechaExpiracionChanged;

  static final DateTime _first = DateTime(2020);
  static final DateTime _last = DateTime(2030);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionFormSection(title: 'Empleado', first: true),
        GestionFormRow(
          label: 'Empleado',
          required: true,
          child: GestionSearchField<String>(
            value: usuario?.id,
            required: true,
            hint: 'Buscar empleado',
            options: usuarios
                .map((UserEntity u) => GestionOption<String>(u.id, u.displayName ?? u.email))
                .toList(),
            onChanged: onUsuarioChanged,
          ),
        ),
        const GestionFormSection(title: 'Formación'),
        // Se elige certificación o curso: al elegir uno se oculta el otro
        if (certificacion != null || curso == null)
          GestionFormRow(
            label: 'Certificación',
            required: true,
            child: GestionSearchField<String>(
              value: certificacion?.id,
              hint: 'Seleccionar certificación',
              options: certificaciones
                  .map(
                    (CertificacionEntity c) => GestionOption<String>(
                      c.id,
                      '${c.codigo} - ${c.nombre}',
                      color: AppColors.primary,
                    ),
                  )
                  .toList(),
              onChanged: onCertificacionChanged,
            ),
          ),
        if (curso != null || certificacion == null)
          GestionFormRow(
            label: 'Curso',
            required: true,
            child: GestionSearchField<String>(
              value: curso?.id,
              hint: 'Seleccionar curso',
              options: cursos
                  .map((CursoEntity c) => GestionOption<String>(c.id, c.nombre, color: AppColors.secondary))
                  .toList(),
              onChanged: onCursoChanged,
            ),
          ),
        const GestionFormSection(title: 'Fechas y horas'),
        GestionFormColumns(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Fecha inicio',
                  required: true,
                  child: GestionDateField(
                    value: fechaInicio,
                    required: true,
                    firstDate: _first,
                    lastDate: _last,
                    onChanged: onFechaInicioChanged,
                  ),
                ),
                GestionFormRow(
                  label: 'Expiración',
                  required: true,
                  child: GestionDateField(
                    // Se recrea si la expiración se autocalcula desde la fecha de inicio
                    key: ValueKey<DateTime?>(fechaExpiracion),
                    value: fechaExpiracion,
                    required: true,
                    firstDate: _first,
                    lastDate: _last,
                    onChanged: onFechaExpiracionChanged,
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestionFormRow(
                  label: 'Fecha fin',
                  required: true,
                  child: GestionDateField(
                    value: fechaFin,
                    required: true,
                    firstDate: _first,
                    lastDate: _last,
                    onChanged: onFechaFinChanged,
                  ),
                ),
                GestionFormRow(
                  label: 'Horas acum.',
                  child: GestionTextField(
                    controller: horas,
                    hint: '0',
                    suffixText: 'horas',
                    textAlign: TextAlign.end,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
          ],
        ),
        GestionFormRow(
          label: 'Observaciones',
          multiline: true,
          child: GestionTextField(controller: observaciones, maxLines: 3),
        ),
      ],
    );
  }
}
