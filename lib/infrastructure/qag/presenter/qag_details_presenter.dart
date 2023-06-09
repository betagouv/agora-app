import 'package:agora/bloc/qag/details/qag_details_view_model.dart';
import 'package:agora/common/extension/date_extension.dart';
import 'package:agora/common/extension/thematique_extension.dart';
import 'package:agora/domain/qag/details/qag_details.dart';

class QagDetailsPresenter {
  static QagDetailsViewModel present(QagDetails qagDetails) {
    final support = qagDetails.support;
    final response = qagDetails.response;
    return QagDetailsViewModel(
      id: qagDetails.id,
      thematique: qagDetails.thematique.toThematiqueViewModel(),
      title: qagDetails.title,
      description: qagDetails.description,
      date: qagDetails.date.formatToDayMonth(),
      username: qagDetails.username,
      canShare: qagDetails.canShare,
      canSupport: qagDetails.canSupport,
      support: QagDetailsSupportViewModel(
        count: support.count,
        isSupported: support.isSupported,
      ),
      response: response != null
          ? QagDetailsResponseViewModel(
              author: response.author,
              authorDescription: response.authorDescription,
              responseDate: response.responseDate.formatToDayMonth(),
              videoUrl: response.videoUrl,
              videoWidth: response.videoWidth,
              videoHeight: response.videoHeight,
              transcription: response.transcription,
              feedbackStatus: response.feedbackStatus,
            )
          : null,
    );
  }
}
