import 'dart:io';

import 'package:agora/domain/qag/details/qag_details.dart';
import 'package:agora/infrastructure/qag/qag_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/dio_utils.dart';

void main() {
  final dioAdapter = DioUtils.dioAdapter();
  final httpClient = DioUtils.agoraDioHttpClient();

  const qagId = "qagId";
  const deviceId = "deviceId";

  group("Fetch qag details", () {
    test("when success and support/response are not null should return qag details", () async {
      // Given
      dioAdapter.onGet(
        "/qags/$qagId",
        (server) => server.reply(
          HttpStatus.ok,
          {
            "id": "qagId",
            "thematiqueId": "thematiqueId",
            "title": "Titre de la QaG",
            "description": "Description textuelle",
            "date": "2024-01-23",
            "username": "Henri J.",
            "support": {"count": 112, "isSupported": true},
            "response": {
              "author": "Olivier Véran",
              "authorDescription": "Ministre délégué auprès de...",
              "responseDate": "2024-02-20",
              "videoUrl": "https://betagouv.github.io/agora-content/QaG-Stormtrooper-Response.mp4",
              "transcription": "Blablabla",
              "feedbackStatus": true
            }
          },
        ),
        headers: {"accept": "application/json", "deviceId": deviceId},
      );

      // When
      final repository = QagDioRepository(httpClient: httpClient);
      final response = await repository.fetchQagDetails(qagId: qagId, deviceId: deviceId);

      // Then
      expect(
        response,
        GetQagDetailsSucceedResponse(
          qagDetails: QagDetails(
            id: qagId,
            thematiqueId: "thematiqueId",
            title: "Titre de la QaG",
            description: "Description textuelle",
            date: DateTime(2024, 1, 23),
            username: "Henri J.",
            support: QagDetailsSupport(count: 112, isSupported: true),
            response: QagDetailsResponse(
              author: "Olivier Véran",
              authorDescription: "Ministre délégué auprès de...",
              responseDate: DateTime(2024, 2, 20),
              videoUrl: "https://betagouv.github.io/agora-content/QaG-Stormtrooper-Response.mp4",
              transcription: "Blablabla",
              feedbackStatus: true,
            ),
          ),
        ),
      );
    });

    test("when success and response is not null and feedbackStatus null should return qag details", () async {
      // Given
      dioAdapter.onGet(
        "/qags/$qagId",
        (server) => server.reply(
          HttpStatus.ok,
          {
            "id": "qagId",
            "thematiqueId": "thematiqueId",
            "title": "Titre de la QaG",
            "description": "Description textuelle",
            "date": "2024-01-23",
            "username": "Henri J.",
            "support": null,
            "response": {
              "author": "Olivier Véran",
              "authorDescription": "Ministre délégué auprès de...",
              "responseDate": "2024-02-20",
              "videoUrl": "https://betagouv.github.io/agora-content/QaG-Stormtrooper-Response.mp4",
              "transcription": "Blablabla",
              "feedbackStatus": null
            }
          },
        ),
        headers: {"accept": "application/json", "deviceId": deviceId},
      );

      // When
      final repository = QagDioRepository(httpClient: httpClient);
      final response = await repository.fetchQagDetails(qagId: qagId, deviceId: deviceId);

      // Then
      expect(
        response,
        GetQagDetailsSucceedResponse(
          qagDetails: QagDetails(
            id: qagId,
            thematiqueId: "thematiqueId",
            title: "Titre de la QaG",
            description: "Description textuelle",
            date: DateTime(2024, 1, 23),
            username: "Henri J.",
            support: null,
            response: QagDetailsResponse(
              author: "Olivier Véran",
              authorDescription: "Ministre délégué auprès de...",
              responseDate: DateTime(2024, 2, 20),
              videoUrl: "https://betagouv.github.io/agora-content/QaG-Stormtrooper-Response.mp4",
              transcription: "Blablabla",
              feedbackStatus: null,
            ),
          ),
        ),
      );
    });

    test("when success and support/response are null should return qag details", () async {
      // Given
      dioAdapter.onGet(
        "/qags/$qagId",
        (server) => server.reply(
          HttpStatus.ok,
          {
            "id": "qagId",
            "thematiqueId": "thematiqueId",
            "title": "Titre de la QaG",
            "description": "Description textuelle",
            "date": "2024-01-23",
            "username": "Henri J.",
            "support": null,
            "response": null,
          },
        ),
        headers: {"accept": "application/json", "deviceId": deviceId},
      );

      // When
      final repository = QagDioRepository(httpClient: httpClient);
      final response = await repository.fetchQagDetails(qagId: qagId, deviceId: deviceId);

      // Then
      expect(
        response,
        GetQagDetailsSucceedResponse(
          qagDetails: QagDetails(
            id: qagId,
            thematiqueId: "thematiqueId",
            title: "Titre de la QaG",
            description: "Description textuelle",
            date: DateTime(2024, 1, 23),
            username: "Henri J.",
            support: null,
            response: null,
          ),
        ),
      );
    });

    test("when failure should return failed", () async {
      // Given
      dioAdapter.onGet(
        "/qags/$qagId",
        (server) => server.reply(HttpStatus.notFound, {}),
        headers: {"accept": "application/json", "deviceId": deviceId},
      );

      // When
      final repository = QagDioRepository(httpClient: httpClient);
      final response = await repository.fetchQagDetails(qagId: qagId, deviceId: deviceId);

      // Then
      expect(response, GetQagDetailsFailedResponse());
    });
  });

  group("Support qag", () {
    test("when success should return success", () async {
      // Given
      dioAdapter.onPost(
        "/qags/$qagId/support",
        (server) => server.reply(HttpStatus.ok, null),
        headers: {"accept": "application/json", "deviceId": deviceId},
      );

      // When
      final repository = QagDioRepository(httpClient: httpClient);
      final response = await repository.supportQag(qagId: qagId, deviceId: deviceId);

      // Then
      expect(response, SupportQagSucceedResponse());
    });

    test("when failure should return failed", () async {
      // Given
      dioAdapter.onPost(
        "/qags/$qagId/support",
        (server) => server.reply(HttpStatus.notFound, {}),
        headers: {"accept": "application/json"},
      );

      // When
      final repository = QagDioRepository(httpClient: httpClient);
      final response = await repository.supportQag(qagId: qagId, deviceId: deviceId);

      // Then
      expect(response, SupportQagFailedResponse());
    });
  });

  group("Delete support qag", () {
    test("when success should return success", () async {
      // Given
      dioAdapter.onDelete(
        "/qags/$qagId/support",
        (server) => server.reply(HttpStatus.ok, null),
        headers: {"accept": "application/json", "deviceId": deviceId},
      );

      // When
      final repository = QagDioRepository(httpClient: httpClient);
      final response = await repository.deleteSupportQag(qagId: qagId, deviceId: deviceId);

      // Then
      expect(response, DeleteSupportQagSucceedResponse());
    });

    test("when failure should return failed", () async {
      // Given
      dioAdapter.onDelete(
        "/qags/$qagId/support",
        (server) => server.reply(HttpStatus.notFound, {}),
        headers: {"accept": "application/json"},
      );

      // When
      final repository = QagDioRepository(httpClient: httpClient);
      final response = await repository.deleteSupportQag(qagId: qagId, deviceId: deviceId);

      // Then
      expect(response, DeleteSupportQagFailedResponse());
    });
  });
}
