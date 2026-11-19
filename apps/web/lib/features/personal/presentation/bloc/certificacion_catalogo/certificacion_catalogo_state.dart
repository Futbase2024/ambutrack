import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

sealed class CertificacionCatalogoState extends Equatable {
  const CertificacionCatalogoState();

  @override
  List<Object?> get props => <Object?>[];
}

final class CertificacionCatalogoInitial extends CertificacionCatalogoState {
  const CertificacionCatalogoInitial();
}

final class CertificacionCatalogoLoading extends CertificacionCatalogoState {
  const CertificacionCatalogoLoading();
}

final class CertificacionCatalogoLoaded extends CertificacionCatalogoState {
  const CertificacionCatalogoLoaded(this.items);

  final List<CertificacionEntity> items;

  @override
  List<Object?> get props => <Object?>[items];
}

final class CertificacionCatalogoError extends CertificacionCatalogoState {
  const CertificacionCatalogoError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
