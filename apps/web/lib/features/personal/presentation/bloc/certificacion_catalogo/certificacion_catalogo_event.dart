import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

sealed class CertificacionCatalogoEvent extends Equatable {
  const CertificacionCatalogoEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class CertificacionCatalogoLoadRequested extends CertificacionCatalogoEvent {
  const CertificacionCatalogoLoadRequested();
}

final class CertificacionCatalogoCreateRequested extends CertificacionCatalogoEvent {
  const CertificacionCatalogoCreateRequested(this.entity);

  final CertificacionEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

final class CertificacionCatalogoUpdateRequested extends CertificacionCatalogoEvent {
  const CertificacionCatalogoUpdateRequested(this.entity);

  final CertificacionEntity entity;

  @override
  List<Object?> get props => <Object?>[entity];
}

final class CertificacionCatalogoDeleteRequested extends CertificacionCatalogoEvent {
  const CertificacionCatalogoDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}
