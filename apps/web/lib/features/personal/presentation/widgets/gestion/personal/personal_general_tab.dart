import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/personal/data/services/tablas_maestras_service.dart';
import 'package:ambutrack_web/features/personal/domain/entities/personal_entity.dart';
import 'package:ambutrack_web/features/personal/domain/entities/poblacion_entity.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_gestion_columns.dart';
import 'package:ambutrack_web/features/personal/presentation/widgets/gestion/personal/personal_lookups.dart';
import 'package:flutter/material.dart';

String? _fecha(DateTime? d) => d == null ? null : GestionFormatters.fecha(d);

String? _telefono(String? t) => (t?.trim().isEmpty ?? true) ? null : GestionFormatters.telefono(t);

/// Pestaña "General" de la ficha del empleado
class PersonalGeneralTab extends StatelessWidget {
  const PersonalGeneralTab({required this.persona, required this.lookups, super.key});

  final PersonalEntity persona;
  final PersonalLookups lookups;

  @override
  Widget build(BuildContext context) {
    final PersonalEntity p = persona;
    return GestionDetailBody(
      children: <Widget>[
        _IdentificacionSection(persona: p),
        const GestionDetailSection(title: 'Contacto'),
        GestionDetailField(label: 'Teléfono', value: _telefono(p.telefono)),
        GestionDetailField(label: 'Móvil', value: _telefono(p.movil)),
        GestionDetailField(label: 'Email', value: p.email),
        const GestionDetailSection(title: 'Dirección'),
        GestionDetailField(label: 'Dirección', value: p.direccion),
        GestionDetailField(label: 'C. Postal', value: p.codigoPostal),
        GestionDetailField(
          label: 'Población',
          child: _PoblacionText(provinciaId: p.provinciaId, poblacionId: p.poblacionId),
        ),
        GestionDetailField(label: 'Provincia', value: lookups.provincias[p.provinciaId]),
        _LaboralSection(persona: p, lookups: lookups),
        const GestionDetailSection(title: 'Asignación por defecto'),
        GestionDetailField(label: 'Base', value: lookups.bases[p.baseId]),
        GestionDetailField(label: 'Dotación', value: lookups.dotaciones[p.dotacionId]),
        GestionDetailField(label: 'Vehículo', value: lookups.vehiculos[p.vehiculoId]),
        GestionDetailField(label: 'Contrato', value: lookups.contratosCliente[p.contratoAsignadoId]),
        const GestionDetailSection(title: 'Acceso'),
        GestionDetailField(label: 'Usuario', value: p.usuario),
        GestionDetailField(label: 'Cuenta vinculada', value: p.usuarioId == null ? 'No' : 'Sí'),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(p.createdAt)),
        GestionDetailField(label: 'Modificado', value: _fecha(p.updatedAt)),
      ],
    );
  }
}

class _IdentificacionSection extends StatelessWidget {
  const _IdentificacionSection({required this.persona});

  final PersonalEntity persona;

  @override
  Widget build(BuildContext context) {
    final PersonalEntity p = persona;
    final DateTime? nacimiento = p.fechaNacimiento;
    final String? edad = nacimiento == null ? null : '${_edad(nacimiento)} años';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionDetailSection(title: 'Datos personales'),
        GestionDetailField(label: 'Nombre', value: p.nombre),
        GestionDetailField(label: 'Apellidos', value: p.apellidos),
        GestionDetailField(label: 'DNI', value: p.dni),
        GestionDetailField(label: 'Nº S. Social', value: p.nass),
        GestionDetailField(label: 'F. nacimiento', value: _fecha(nacimiento)),
        GestionDetailField(label: 'Edad', value: edad),
      ],
    );
  }

  static int _edad(DateTime nacimiento) {
    final DateTime hoy = DateTime.now();
    int edad = hoy.year - nacimiento.year;
    if (hoy.month < nacimiento.month || (hoy.month == nacimiento.month && hoy.day < nacimiento.day)) {
      edad--;
    }
    return edad;
  }
}

class _LaboralSection extends StatelessWidget {
  const _LaboralSection({required this.persona, required this.lookups});

  final PersonalEntity persona;
  final PersonalLookups lookups;

  @override
  Widget build(BuildContext context) {
    final PersonalEntity p = persona;
    final bool tieneCategoria = p.categoria?.trim().isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GestionDetailSection(title: 'Datos laborales'),
        GestionDetailField(
          label: 'Categoría',
          value: tieneCategoria ? null : lookups.categorias[p.categoriaId],
          child: tieneCategoria ? PersonalCategoriaDot(categoria: p.categoria) : null,
        ),
        GestionDetailField(label: 'Servicio', child: PersonalServicioDot(servicio: p.categoriaServicio)),
        GestionDetailField(label: 'Puesto', value: lookups.puestos[p.puestoTrabajoId]),
        GestionDetailField(label: 'Tipo contrato', value: lookups.tiposContrato[p.contratoId]),
        GestionDetailField(label: 'Empresa', value: lookups.empresas[p.empresaId] ?? p.empresa),
        GestionDetailField(label: 'F. inicio', value: _fecha(p.fechaInicio)),
        GestionDetailField(label: 'F. alta', value: _fecha(p.fechaAlta)),
        GestionDetailField(label: 'Antigüedad', value: _fecha(p.dataAnti)),
        GestionDetailField(
          label: 'TES',
          value: p.tesSiNo == null ? null : (p.tesSiNo! ? 'Sí' : 'No'),
        ),
        GestionDetailField(label: 'Estado', child: PersonalEstadoDot(activo: p.activo)),
      ],
    );
  }
}

/// Nombre de la población (se carga por provincia con caché)
class _PoblacionText extends StatefulWidget {
  const _PoblacionText({required this.provinciaId, required this.poblacionId});

  final String? provinciaId;
  final String? poblacionId;

  @override
  State<_PoblacionText> createState() => _PoblacionTextState();
}

class _PoblacionTextState extends State<_PoblacionText> {
  String? _nombre;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.provinciaId == null || widget.poblacionId == null) {
      return;
    }
    final List<PoblacionEntity> poblaciones =
        await TablasMaestrasService().getPoblaciones(provinciaId: widget.provinciaId);
    final String? nombre = poblaciones
        .where((PoblacionEntity p) => p.id == widget.poblacionId)
        .map((PoblacionEntity p) => p.nombre)
        .firstOrNull;
    if (mounted && nombre != null) {
      setState(() => _nombre = nombre);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      GestionFormatters.texto(_nombre),
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: _nombre == null ? AppColors.gray300 : AppColors.gray900,
      ),
    );
  }
}
