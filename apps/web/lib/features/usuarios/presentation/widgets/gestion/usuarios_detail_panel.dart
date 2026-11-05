import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/usuarios/presentation/widgets/gestion/usuarios_gestion_columns.dart';
import 'package:flutter/material.dart';

/// Ficha lateral del usuario seleccionado
class UsuariosDetailPanel extends StatelessWidget {
  const UsuariosDetailPanel({
    required this.usuario,
    required this.onEdit,
    required this.onResetPassword,
    required this.onDelete,
    super.key,
  });

  final UserEntity? usuario;
  final VoidCallback onEdit;
  final VoidCallback onResetPassword;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final UserEntity? u = usuario;
    if (u == null) {
      return const GestionDetailEmpty(message: 'Selecciona un usuario para ver su ficha');
    }
    return GestionDetailPanel(
      key: ValueKey<String>(u.id),
      title: usuarioNombre(u),
      badges: <Widget>[
        if (u.rol != null) UsuarioRolDot(rol: u.rol),
        UsuarioEstadoDot(activo: usuarioActivo(u)),
      ],
      tabs: <GestionDetailTab>[
        GestionDetailTab(label: 'General', child: _UsuarioGeneralTab(usuario: u)),
      ],
      actions: <Widget>[
        _PanelButton(label: 'Editar', icon: Icons.edit_outlined, color: AppColors.primary, onPressed: onEdit),
        _PanelButton(
          label: 'Contraseña',
          icon: Icons.lock_reset,
          color: AppColors.warning,
          onPressed: onResetPassword,
        ),
        _PanelButton(label: 'Eliminar', icon: Icons.delete_outline, color: AppColors.error, onPressed: onDelete),
      ],
    );
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _UsuarioGeneralTab extends StatelessWidget {
  const _UsuarioGeneralTab({required this.usuario});

  final UserEntity usuario;

  @override
  Widget build(BuildContext context) {
    final UserEntity u = usuario;
    return GestionDetailBody(
      children: <Widget>[
        const GestionDetailSection(title: 'Identificación'),
        GestionDetailField(label: 'Nombre', value: usuarioNombre(u)),
        GestionDetailField(label: 'DNI', value: u.dni),
        const GestionDetailSection(title: 'Contacto'),
        GestionDetailField(label: 'Email', value: u.email),
        GestionDetailField(
          label: 'Teléfono',
          value: u.phoneNumber == null ? null : GestionFormatters.telefono(u.phoneNumber),
        ),
        const GestionDetailSection(title: 'Acceso'),
        GestionDetailField(label: 'Rol', child: UsuarioRolDot(rol: u.rol)),
        GestionDetailField(label: 'Estado', child: UsuarioEstadoDot(activo: usuarioActivo(u))),
        GestionDetailField(label: 'Email verificado', value: u.isEmailVerified ? 'Sí' : 'No'),
        const GestionDetailSection(title: 'Organización'),
        GestionDetailField(label: 'Empresa', value: u.empresaNombre),
        GestionDetailField(label: 'Ficha personal', value: u.personalId == null ? 'No vinculada' : 'Vinculada'),
        const GestionDetailSection(title: 'Registro'),
        GestionDetailField(label: 'Alta', value: GestionFormatters.fecha(u.createdAt)),
        GestionDetailField(label: 'Modificado', value: GestionFormatters.fecha(u.updatedAt)),
      ],
    );
  }
}
