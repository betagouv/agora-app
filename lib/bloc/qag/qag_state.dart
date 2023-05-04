import 'package:agora/bloc/qag/qag_view_model.dart';
import 'package:equatable/equatable.dart';

abstract class QagState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QagInitialLoadingState extends QagState {}

class QagFetchedState extends QagState {
  final List<QagResponseViewModel> qagResponseViewModels;
  final List<QagViewModel> popularViewModels;
  final List<QagViewModel> latestViewModels;
  final List<QagViewModel> supportingViewModels;

  QagFetchedState({
    required this.qagResponseViewModels,
    required this.popularViewModels,
    required this.latestViewModels,
    required this.supportingViewModels,
  });

  @override
  List<Object> get props => [
        qagResponseViewModels,
        popularViewModels,
        latestViewModels,
        supportingViewModels,
      ];
}

class QagErrorState extends QagState {}