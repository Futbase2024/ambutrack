import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/auditoria/presentation/widgets/historial/registro_historial_tab.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/gestion/paciente_gestion_columns.dart';
import 'package:ambutrack_web/features/servicios/pacientes/presentation/widgets/gestion/paciente_lookups.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del paciente seleccionado
class PacienteDetailPanel extends StatelessWidget {
  const PacienteDetailPanel({
    required this.paciente,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final PacienteEntity? paciente;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final PacienteEntity? p = paciente;
    if (p == null) {
      return const GestionDetailEmpty(
        message: 'Selecciona un paciente para ver su ficha',
      );
    }
    return GestionDetailPanel(
      key: ValueKey<String>(p.id),
      title: p.nombreCompleto,
      badges: <Widget>[
        PacienteEstadoDot(activo: p.activo),
        if (pacienteDatosPendientes(p))
          const GestionDotLabel(label: 'Datos de contacto pendientes', color: AppColors.warning),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(
          label: 'General',
          child: _ConLookups(
            builder: (PacienteLookups l) => _PacienteGeneralTab(paciente: p, lookups: l),
          ),
        ),
        GestionDetailTab(
          label: 'Administrativo',
          child: _ConLookups(
            builder: (PacienteLookups l) => _PacienteAdministrativoTab(paciente: p, lookups: l),
          ),
        ),
        GestionDetailTab(label: 'Cambios', child: RegistroHistorialTab(tabla: 'pacientes', registroId: p.id)),
      ],
      actions: <Widget>[
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Editar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Eliminar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
            minimumSize: const Size(0, 34),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Carga los nombres de las tablas maestras (con caché) y construye la pestaña.
/// Mientras cargan (o si fallan) se muestran los ids originales.
class _ConLookups extends StatelessWidget {
  const _ConLookups({required this.builder});

  final Widget Function(PacienteLookups lookups) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PacienteLookups>(
      future: PacienteLookups.load(),
      builder: (BuildContext context, AsyncSnapshot<PacienteLookups> snap) =>
          builder(snap.data ?? const PacienteLookups()),
    );
  }
}

class _PacienteGeneralTab extends StatelessWidget {
  const _PacienteGeneralTab({required this.paciente, required this.lookups});

  final PacienteEntity paciente;
  final PacienteLookups lookups;

  @override
  Widget build(BuildContext context) {
    final PacienteEntity p = paciente;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Identificación', value: p.identificacion),
        GestionDetailField(label: 'Documento', value: pacienteDocumento(p)),
        GestionDetailField(label: 'Seg. Social', value: p.seguridadSocial),
        GestionDetailField(label: 'Nº historia', value: p.numHistoria),
        const GestionDetailSection(title: 'Datos personales'),
        GestionDetailField(label: 'Sexo', value: p.sexo),
        GestionDetailField(
          label: 'Nacimiento',
          value: '${GestionFormatters.fecha(p.fechaNacimiento)} (${p.edad} años)',
        ),
        GestionDetailField(label: 'País origen', value: p.paisOrigen),
        GestionDetailField(label: 'Profesión', value: p.profesion),
        const GestionDetailSection(title: 'Contacto'),
        GestionDetailField(
          label: 'Móvil',
          value: p.telefonoMovil == null ? null : GestionFormatters.telefono(p.telefonoMovil),
        ),
        GestionDetailField(
          label: 'Fijo',
          value: p.telefonoFijo == null ? null : GestionFormatters.telefono(p.telefonoFijo),
        ),
        GestionDetailField(label: 'Email', value: p.email),
        const GestionDetailSection(title: 'Domicilio'),
        GestionDetailField(label: 'Dirección', value: p.domicilioDireccion),
        GestionDetailField(label: 'Piso', value: p.domicilioPiso),
        GestionDetailField(label: 'Puerta', value: p.domicilioPuerta),
        GestionDetailField(label: 'Localidad', value: PacienteLookups.nombre(lookups.localidades, p.localidadId)),
        GestionDetailField(label: 'Provincia', value: PacienteLookups.nombre(lookups.provincias, p.provinciaId)),
        const GestionDetailSection(title: 'Recogida'),
        GestionDetailField(label: 'Días', value: _diasRecogida(p)),
        GestionDetailField(label: 'Piso', value: p.recogidaPiso),
        GestionDetailField(label: 'Puerta', value: p.recogidaPuerta),
        GestionDetailField(label: 'Info. adicional', value: p.recogidaInformacionAdicional),
      ],
    );
  }

  static String _diasRecogida(PacienteEntity p) {
    final String dias = p.diasRecogidaFormateados;
    return p.recogidaFestivos ? '$dias + Festivos' : dias;
  }
}

class _PacienteAdministrativoTab extends StatelessWidget {
  const _PacienteAdministrativoTab({required this.paciente, required this.lookups});

  final PacienteEntity paciente;
  final PacienteLookups lookups;

  @override
  Widget build(BuildContext context) {
    final PacienteEntity p = paciente;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Asistencial'),
        GestionDetailField(
          label: 'Centro hosp.',
          value: PacienteLookups.nombre(lookups.centros, p.centroHospitalarioId),
        ),
        GestionDetailField(
          label: 'Facultativo',
          value: PacienteLookups.nombre(lookups.facultativos, p.facultativoId),
        ),
        const GestionDetailSection(title: 'Aseguradora'),
        GestionDetailField(label: 'Mutua', value: p.mutuaAseguradora),
        GestionDetailField(label: 'Nº póliza', value: p.numPoliza),
        const GestionDetailSection(title: 'Consentimientos'),
        GestionDetailField(
          label: 'Informado',
          value: _consentimiento(p.consentimientoInformado, p.consentimientoInformadoFecha),
        ),
        GestionDetailField(
          label: 'RGPD',
          value: _consentimiento(p.consentimientoRgpd, p.consentimientoRgpdFecha),
        ),
        const GestionDetailSection(title: 'Observaciones'),
        _ObservacionesText(text: p.observaciones),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(
          label: 'Alta',
          value: p.createdAt == null ? null : GestionFormatters.fecha(p.createdAt),
        ),
        GestionDetailField(
          label: 'Modificado',
          value: p.updatedAt == null ? null : GestionFormatters.fecha(p.updatedAt),
        ),
      ],
    );
  }

  static String _consentimiento(bool otorgado, DateTime? fecha) {
    if (!otorgado) {
      return 'No';
    }
    return fecha == null ? 'Sí' : 'Sí (${GestionFormatters.fecha(fecha)})';
  }
}

class _ObservacionesText extends StatelessWidget {
  const _ObservacionesText({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final bool hasText = text?.trim().isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        GestionFormatters.texto(text),
        style: TextStyle(
          fontSize: 12.5,
          height: 1.4,
          color: hasText ? AppColors.gray800 : AppColors.gray300,
        ),
      ),
    );
  }
}
