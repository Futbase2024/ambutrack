import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/loading/app_loading_indicator.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/perfil_bloc.dart';
import '../bloc/perfil_event.dart';
import '../bloc/perfil_state.dart';
import '../widgets/perfil_cambiar_password_dialog.dart';
import '../widgets/perfil_editar_dialog.dart';
import '../widgets/perfil_header.dart';

/// Página principal del perfil de usuario
class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<PerfilBloc>(
        create: (BuildContext _) => getIt<PerfilBloc>()..add(const PerfilEvent.loaded()),
        child: const _PerfilView(),
      ),
    );
  }
}

/// Vista principal del perfil
class _PerfilView extends StatelessWidget {
  const _PerfilView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<PerfilBloc, PerfilState>(
      listener: _handleStateChanges,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: BlocBuilder<PerfilBloc, PerfilState>(
          builder: (BuildContext context, PerfilState state) {
            return state.when(
              initial: () => const Center(child: AppLoadingIndicator()),
              loading: () => const Center(child: AppLoadingIndicator()),
              loaded: (UserEntity user) => _LoadedContent(user: user),
              updating: () => const _UpdatingOverlay(),
              updateSuccess: (String message) => const Center(child: AppLoadingIndicator()),
              error: (String message) => _ErrorView(message: message),
            );
          },
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, PerfilState state) {
    state.whenOrNull(
      updateSuccess: (String message) {
        _showSuccessDialog(context, message);
      },
      error: (String message) {
        _showErrorDialog(context, message);
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingXl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Perfil Actualizado',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondaryLight,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Aceptar',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingXl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Error',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondaryLight,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contenido cuando el perfil está cargado
class _LoadedContent extends StatelessWidget {
  const _LoadedContent({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      child: Column(
        children: <Widget>[
          // Layout principal: Card azul a la izquierda, cards de info a la derecha
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Izquierda - Card azul con avatar
              SizedBox(
                width: 380,
                child: PerfilHeader(user: user),
              ),
              const SizedBox(width: AppSizes.spacingXl),
              // Derecha - Cards de información apilados
              Expanded(
                child: Column(
                  children: <Widget>[
                    _InformacionBasicaCard(user: user),
                    const SizedBox(height: AppSizes.spacingXl),
                    _InformacionSesionCard(user: user),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingXl),
          // Botones de acción centrados
          SizedBox(
            width: 600,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AppButton(
                    label: 'Editar Perfil',
                    icon: Icons.edit_outlined,
                    onPressed: () => _showEditarPerfilDialog(context, user),
                  ),
                ),
                const SizedBox(width: AppSizes.spacing),
                Expanded(
                  child: AppButton(
                    label: 'Cambiar Contraseña',
                    icon: Icons.lock_outlined,
                    variant: AppButtonVariant.outline,
                    onPressed: () => _showCambiarPasswordDialog(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditarPerfilDialog(BuildContext context, UserEntity user) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => BlocProvider<PerfilBloc>.value(
        value: context.read<PerfilBloc>(),
        child: PerfilEditarDialog(user: user),
      ),
    );
  }

  void _showCambiarPasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => BlocProvider<PerfilBloc>.value(
        value: context.read<PerfilBloc>(),
        child: const PerfilCambiarPasswordDialog(),
      ),
    );
  }
}

/// Card de información básica
class _InformacionBasicaCard extends StatelessWidget {
  const _InformacionBasicaCard({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Información Básica',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Nombre completo',
            value: user.displayName ?? 'Sin nombre',
          ),
          const SizedBox(height: AppSizes.spacing),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Correo electrónico',
            value: user.email,
          ),
          const SizedBox(height: AppSizes.spacing),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: user.phoneNumber ?? 'No registrado',
          ),
          if (user.emailVerified) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.verified,
                  size: 20,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Text(
                  'Email verificado',
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.font,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Card de información de sesión
class _InformacionSesionCard extends StatelessWidget {
  const _InformacionSesionCard({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.gray200),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.gray900.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Información de Sesión',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingLarge),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'ID de usuario',
            value: user.uid,
          ),
          const SizedBox(height: AppSizes.spacing),
          _InfoRow(
            icon: Icons.business_outlined,
            label: 'Empresa',
            value: user.empresaNombre ?? 'No asignada',
          ),
          const SizedBox(height: AppSizes.spacing),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Fecha de registro',
            value: dateFormat.format(user.createdAt),
          ),
          if (user.lastLoginAt != null) ...<Widget>[
            const SizedBox(height: AppSizes.spacing),
            _InfoRow(
              icon: Icons.login_outlined,
              label: 'Último acceso',
              value: dateFormat.format(user.lastLoginAt!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget reutilizable para mostrar una fila de información
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryLight,
        ),
        const SizedBox(width: AppSizes.spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontXs,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.font,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Overlay mostrado durante actualización
class _UpdatingOverlay extends StatelessWidget {
  const _UpdatingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingXl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: AppSizes.spacingLarge),
              Text(
                'Actualizando perfil...',
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMedium,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vista de error
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.spacingLarge),
            Text(
              'Error al cargar el perfil',
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacing),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: AppSizes.font,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingXl),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PerfilBloc>().add(const PerfilEvent.loaded());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
