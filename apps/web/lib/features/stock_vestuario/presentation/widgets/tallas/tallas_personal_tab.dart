import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/widgets/dialogs/result_dialog.dart';
import 'package:ambutrack_web/core/widgets/gestion/gestion_layout.dart';
import 'package:ambutrack_web/features/stock_vestuario/data/repositories/solicitudes_vestuario_repository_impl.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/cubit/tallas_personal_cubit.dart';
import 'package:ambutrack_web/features/stock_vestuario/presentation/widgets/tallas/tallas_personal_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pestaña "Tallas": tallas registradas del trabajador, editables desde gestión
class TallasPersonalTab extends StatelessWidget {
  const TallasPersonalTab({required this.personalId, required this.trabajador, this.prenda, super.key});

  final String personalId;
  final String trabajador;

  /// Prenda de referencia: se resalta la talla habitual del trabajador para ella
  final String? prenda;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TallasPersonalCubit>(
      key: ValueKey<String>(personalId),
      create: (BuildContext _) =>
          TallasPersonalCubit(SolicitudesVestuarioRepositoryImpl(), personalId: personalId)..cargar(),
      child: _TallasBody(trabajador: trabajador, prenda: prenda),
    );
  }
}

class _TallasBody extends StatelessWidget {
  const _TallasBody({required this.trabajador, required this.prenda});

  final String trabajador;
  final String? prenda;

  Future<void> _editar(BuildContext context) async {
    final TallasPersonalCubit cubit = context.read<TallasPersonalCubit>();
    final TallasPersonalEntity? editadas = await editarTallasPersonal(
      context,
      personalId: cubit.personalId,
      trabajador: trabajador,
      tallas: cubit.state.tallas,
    );
    if (editadas == null) {
      return;
    }
    final String? error = await cubit.guardar(editadas);
    if (!context.mounted) {
      return;
    }
    await showResultDialog(
      context: context,
      title: error == null ? 'Tallas guardadas' : 'Error al guardar las tallas',
      message: error == null
          ? 'Se han actualizado las tallas de $trabajador.'
          : 'No se pudieron guardar las tallas de $trabajador.',
      details: error,
      type: error == null ? ResultType.success : ResultType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TallasPersonalCubit, TallasPersonalState>(
      builder: (BuildContext context, TallasPersonalState state) {
        if (!state.cargado) {
          return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
        }
        final TallasPersonalEntity? t = state.tallas;
        final String? habitual = prenda == null ? null : t?.tallaPara(prenda!);
        return GestionDetailBody(
          children: <Widget>[
            if (prenda != null) ...<Widget>[
              const GestionDetailSection(title: 'Para esta prenda'),
              GestionDetailField(label: 'Talla habitual', value: habitual),
            ],
            const GestionDetailSection(title: 'Tallas registradas'),
            if (state.error != null) _TallasMensaje(texto: state.error!, color: AppColors.error),
            if (t == null && state.error == null)
              const _TallasMensaje(texto: 'El trabajador no tiene tallas registradas', color: AppColors.gray500),
            GestionDetailField(label: 'Camiseta', value: t?.camiseta),
            GestionDetailField(label: 'Polo', value: t?.polo),
            GestionDetailField(label: 'Sudadera', value: t?.sudadera),
            GestionDetailField(label: 'Chaqueta', value: t?.chaqueta),
            GestionDetailField(label: 'Pantalón', value: t?.pantalon),
            GestionDetailField(label: 'Calzado', value: t?.calzado),
            GestionDetailField(label: 'Guantes', value: t?.guantes),
            GestionDetailField(label: 'Observaciones', value: t?.observaciones),
            GestionDetailField(
              label: 'Actualizado',
              value: t?.updatedAt == null ? null : GestionFormatters.fecha(t!.updatedAt),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: state.guardando ? null : () => _editar(context),
                icon: const Icon(Icons.straighten, size: 16),
                label: Text(t == null ? 'Registrar tallas' : 'Editar tallas'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 34),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TallasMensaje extends StatelessWidget {
  const _TallasMensaje({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(texto, style: TextStyle(fontSize: 12.5, color: color)),
    );
  }
}
