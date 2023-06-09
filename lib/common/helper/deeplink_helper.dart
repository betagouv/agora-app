import 'dart:async';
import 'dart:ui';

import 'package:agora/common/log/log.dart';
import 'package:uni_links/uni_links.dart';

class DeeplinkHelper {
  static const String _consultationPath = "consultations";
  static const String _qagPath = "qags";
  static final _uuidRegExp =
      RegExp(r'[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}');

  StreamSubscription<Uri?>? _sub;

  Future<void> onInitial({
    required Function(String consutlationId) onConsultationSuccessCallback,
    required Function(String qagId) onQagSuccessCallback,
  }) async {
    final uri = await getInitialUri();
    if (uri != null) {
      Log.d("deeplink initiate uri : $uri");
      final featurePath = uri.pathSegments.first;
      final id = uri.pathSegments.last;
      switch (featurePath) {
        case _consultationPath:
          _handleDeeplink(
            id: id,
            onMatchSuccessCallback: (id) => onConsultationSuccessCallback(id),
            onMatchFailedCallback: () => Log.e("deeplink initiate uri : no consultation id match error"),
          );
          break;
        case _qagPath:
          _handleDeeplink(
            id: id,
            onMatchSuccessCallback: (id) => onQagSuccessCallback(id),
            onMatchFailedCallback: () => Log.e("deeplink initiate uri : no qag id match error"),
          );
          break;
        default:
          Log.e("deeplink initiate uri : unknown path error: ${uri.path}");
          break;
      }
    } else {
      Log.d("deeplink initiate uri : null uri error");
    }
  }

  Future<void> onGetUriLinkStream({
    required Function(String consutlationId) onConsultationSuccessCallback,
    required Function(String qagId) onQagSuccessCallback,
  }) async {
    _sub = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          final featurePath = uri.pathSegments.first;
          final id = uri.pathSegments.last;
          switch (featurePath) {
            case _consultationPath:
              _handleDeeplink(
                id: id,
                onMatchSuccessCallback: (id) => onConsultationSuccessCallback(id),
                onMatchFailedCallback: () => Log.e("deeplink listen uri : no consultation id match error"),
              );
              break;
            case _qagPath:
              _handleDeeplink(
                id: id,
                onMatchSuccessCallback: (id) => onQagSuccessCallback(id),
                onMatchFailedCallback: () => Log.e("deeplink listen uri : no qag id match error"),
              );
              break;
            default:
              Log.e("deeplink listen uri : unknown path error: ${uri.path}");
              break;
          }
        } else {
          Log.d("deeplink listen uri : null uri error");
        }
      },
      onError: (Object err) {
        Log.d("link error: $err");
      },
    );
  }

  void _handleDeeplink({
    required String id,
    required Function(String id) onMatchSuccessCallback,
    required VoidCallback onMatchFailedCallback,
  }) {
    final RegExpMatch? match = _uuidRegExp.firstMatch(id);
    if (match != null && match[0] != null) {
      onMatchSuccessCallback(match[0]!);
    } else {
      onMatchFailedCallback();
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
