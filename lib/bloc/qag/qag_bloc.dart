import 'package:agora/bloc/qag/qag_event.dart';
import 'package:agora/bloc/qag/qag_state.dart';
import 'package:agora/common/helper/device_info_helper.dart';
import 'package:agora/infrastructure/qag/presenter/qag_presenter.dart';
import 'package:agora/infrastructure/qag/qag_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QagBloc extends Bloc<FetchQagsEvent, QagState> {
  final QagRepository qagRepository;
  final DeviceInfoHelper deviceInfoHelper;

  QagBloc({
    required this.qagRepository,
    required this.deviceInfoHelper,
  }) : super(QagInitialLoadingState()) {
    on<FetchQagsEvent>(_handleQag);
  }

  Future<void> _handleQag(
    FetchQagsEvent event,
    Emitter<QagState> emit,
  ) async {
    final deviceId = await deviceInfoHelper.getDeviceId();
    if (deviceId == null) {
      emit(QagErrorState());
      return;
    }
    final response = await qagRepository.fetchQags(deviceId: deviceId, thematiqueId: event.thematiqueId);
    if (response is GetQagsSucceedResponse) {
      final qagResponseViewModels = QagPresenter.presentQagResponse(response.qagResponses);
      final qagPopularViewModels = QagPresenter.presentQag(response.qagPopular);
      final qagLatestViewModels = QagPresenter.presentQag(response.qagLatest);
      final qagSupportingViewModels = QagPresenter.presentQag(response.qagSupporting);
      emit(
        QagFetchedState(
          qagResponseViewModels: qagResponseViewModels,
          popularViewModels: qagPopularViewModels,
          latestViewModels: qagLatestViewModels,
          supportingViewModels: qagSupportingViewModels,
        ),
      );
    } else {
      emit(QagErrorState());
    }
  }
}
