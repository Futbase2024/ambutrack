import 'dart:convert';

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/administracion/multicentro/presentation/widgets/multicentro_columns.dart';
import 'package:ambutrack_web/features/administracion/shared/admin_shared_widgets.dart';
import 'package:flutter/material.dart';

/// Ficha lateral de la empresa seleccionada (solo lectura)
class MulticentroDetailPanel extends StatelessWidget {
  const MulticentroDetailPanel({
    required this.empresa,
    required this.usuarios,
    super.key,
  });

  final EmpresaTenantEntity? empresa;
  final List<UserEntity> usuarios;

  @override
  Widget build(BuildContext context) {
    final EmpresaTenantEntity? e = empresa;
    if (e == null) {
      return const GestionDetailEmpty(message: 'Selecciona una empresa para ver su ficha');
    }
    return GestionDetailPanel(
      title: e.nombre,
      badges: <Widget>[
        EmpresaEstadoDot(activa: e.activo),
        GestionDotLabel(label: '${usuarios.length} usuarios', color: AppColors.primary),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'Datos', child: _EmpresaDatosTab(empresa: e)),
        GestionDetailTab(
          label: 'Usuarios (${usuarios.length})',
          child: AdminUsuariosList(
            usuarios: usuarios,
            emptyMessage: 'Esta empresa no tiene usuarios asignados',
          ),
        ),
        GestionDetailTab(label: 'Configuración', child: _EmpresaConfigTab(empresa: e)),
      ],
    );
  }
}

class _EmpresaDatosTab extends StatelessWidget {
  const _EmpresaDatosTab({required this.empresa});

  final EmpresaTenantEntity empresa;

  @override
  Widget build(BuildContext context) {
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Nombre', value: empresa.nombre),
        GestionDetailField(label: 'CIF', value: empresa.cif),
        GestionDetailField(label: 'Razón social', value: empresa.razonSocial),
        const GestionDetailSection(title: 'Contacto'),
        GestionDetailField(label: 'Dirección', value: empresa.direccion),
        GestionDetailField(label: 'Teléfono', value: GestionFormatters.telefono(empresa.telefono)),
        GestionDetailField(label: 'Email', value: empresa.email),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(empresa.createdAt)),
        GestionDetailField(
          label: 'Última modif.',
          value: GestionFormatters.fecha(empresa.updatedAt),
        ),
        GestionDetailField(label: 'Identificador', value: empresa.id),
      ],
    );
  }
}

class _EmpresaConfigTab extends StatelessWidget {
  const _EmpresaConfigTab({required this.empresa});

  final EmpresaTenantEntity empresa;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> config = empresa.configuracion;
    if (config.isEmpty) {
      return const GestionDetailEmpty(
        message: 'La empresa no tiene parámetros propios en la columna "configuracion"',
      );
    }
    final List<String> claves = config.keys.toList()..sort();
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Parámetros (empresas.configuracion)'),
        for (final String clave in claves)
          GestionDetailField(label: clave, value: _formatValue(config[clave])),
      ],
    );
  }

  static String _formatValue(Object? value) {
    if (value == null) {
      return GestionFormatters.vacio;
    }
    if (value is Map || value is List) {
      return jsonEncode(value);
    }
    return value.toString();
  }
}
