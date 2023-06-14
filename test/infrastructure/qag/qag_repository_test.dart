import 'dart:io';

import 'package:agora/domain/qag/details/qag_details.dart';
import 'package:agora/domain/qag/moderation/qag_moderation_list.dart';
import 'package:agora/domain/qag/qag.dart';
import 'package:agora/domain/qag/qag_paginated.dart';
import 'package:agora/domain/qag/qag_paginated_filter.dart';
import 'package:agora/domain/qag/qag_response.dart';
import 'package:agora/domain/qag/qags_error_type.dart';
import 'package:agora/domain/thematique/thematique.dart';
import 'package:agora/infrastructure/qag/qag_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/common/fake_crashlytics_helper.dart';
import '../../utils/dio_utils.dart';

void main() {
  final dioAdapter = DioUtils.dioAdapter();
  final httpClient = DioUtils.agoraDioHttpClient();
  final fakeCrashlyticsHelper = FakeCrashlyticsHelper();

  const qagId = "qagId";
  const thematiqueId = "thematiqueId";

  group("Create qag", () {
    test("when success should return success", () async {
      // Given
      dioAdapter.onPost(
        "/qags",
        (server) => server.reply(
          HttpStatus.ok,
          {"qagId": qagId},
        ),
        data: {
          "title": "qag title",
          "description": "qag description",
          "author": "qag author",
          "thematiqueId": "thematiqueId",
        },
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.createQag(
        title: "qag title",
        description: "qag description",
        author: "qag author",
        thematiqueId: thematiqueId,
      );

      // Then
      expect(response, CreateQagSucceedResponse(qagId: qagId));
    });

    test("when failure should return failed", () async {
      // Given
      dioAdapter.onPost(
        "/qags",
        (server) => server.reply(HttpStatus.notFound, {}),
        data: {
          "title": "qag title",
          "description": "qag description",
          "author": "qag author",
          "thematiqueId": "thematiqueId",
        },
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.createQag(
        title: "qag title",
        description: "qag description",
        author: "qag author",
        thematiqueId: thematiqueId,
      );

      // Then
      expect(response, CreateQagFailedResponse());
    });
  });

  group("Fetch qags", () {
    test("when success and error message null should return qags", () async {
      // Given
      dioAdapter.onGet(
        "/qags",
        queryParameters: {"thematiqueId": thematiqueId},
        (server) => server.reply(
          HttpStatus.ok,
          {
            "responses": [
              {
                "qagId": "qagId",
                "thematique": {"label": "Transports", "picto": "🚊"},
                "title": "Pourquoi ... ?",
                "author": "Olivier Véran",
                "authorPortraitUrl": "authorPortraitUrl",
                "responseDate": "2023-01-23"
              }
            ],
            "qags": {
              "popular": [
                {
                  "qagId": "id1",
                  "thematique": {"label": "Transports", "picto": "🚊"},
                  "title": "title1",
                  "username": "username1",
                  "date": "2023-01-01",
                  "support": {
                    "count": 116,
                    "isSupported": true,
                  }
                },
              ],
              "latest": [
                {
                  "qagId": "id2",
                  "thematique": {"label": "Transports", "picto": "🚊"},
                  "title": "title2",
                  "username": "username2",
                  "date": "2023-02-01",
                  "support": {
                    "count": 11,
                    "isSupported": false,
                  }
                },
              ],
              "supporting": [
                {
                  "qagId": "id3",
                  "thematique": {"label": "Transports", "picto": "🚊"},
                  "title": "title3",
                  "username": "username3",
                  "date": "2023-03-01",
                  "support": {
                    "count": 2,
                    "isSupported": true,
                  },
                }
              ],
              "askQagErrorText": null,
            }
          },
        ),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQags(thematiqueId: thematiqueId);

      // Then
      expect(
        response,
        GetQagsSucceedResponse(
          qagResponses: [
            QagResponse(
              qagId: "qagId",
              thematique: Thematique(picto: "🚊", label: "Transports"),
              title: "Pourquoi ... ?",
              author: "Olivier Véran",
              authorPortraitUrl: "authorPortraitUrl",
              responseDate: DateTime(2023, 1, 23),
            ),
          ],
          qagPopular: [
            Qag(
              id: "id1",
              thematique: Thematique(picto: "🚊", label: "Transports"),
              title: "title1",
              username: "username1",
              date: DateTime(2023, 1, 1),
              supportCount: 116,
              isSupported: true,
            ),
          ],
          qagLatest: [
            Qag(
              id: "id2",
              thematique: Thematique(picto: "🚊", label: "Transports"),
              title: "title2",
              username: "username2",
              date: DateTime(2023, 2, 1),
              supportCount: 11,
              isSupported: false,
            ),
          ],
          qagSupporting: [
            Qag(
              id: "id3",
              thematique: Thematique(picto: "🚊", label: "Transports"),
              title: "title3",
              username: "username3",
              date: DateTime(2023, 3, 1),
              supportCount: 2,
              isSupported: true,
            ),
          ],
          errorCase: null,
        ),
      );
    });

    test("when success and error message not null should return qags", () async {
      // Given
      dioAdapter.onGet(
        "/qags",
        queryParameters: {"thematiqueId": thematiqueId},
        (server) => server.reply(
          HttpStatus.ok,
          {
            "responses": [],
            "qags": {
              "popular": [],
              "latest": [],
              "supporting": [],
              "askQagErrorText": "Une erreur est survenue",
            }
          },
        ),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQags(thematiqueId: thematiqueId);

      // Then
      expect(
        response,
        GetQagsSucceedResponse(
          qagResponses: [],
          qagPopular: [],
          qagLatest: [],
          qagSupporting: [],
          errorCase: "Une erreur est survenue",
        ),
      );
    });

    test("when failure with connection timeout should return failed", () async {
      // Given
      dioAdapter.onGet(
        "/qags",
        (server) {
          server.throws(
            404,
            DioError.connectionTimeout(
              timeout: Duration(seconds: 60),
              requestOptions: RequestOptions(),
            ),
          );
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQags(thematiqueId: thematiqueId);

      // Then
      expect(response, GetQagsFailedResponse(errorType: QagsErrorType.timeout));
    });

    test("when failure with receive timeout should return failed", () async {
      // Given
      dioAdapter.onGet(
        "/qags",
        (server) {
          server.throws(
            404,
            DioError.receiveTimeout(
              timeout: Duration(seconds: 60),
              requestOptions: RequestOptions(),
            ),
          );
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQags(thematiqueId: thematiqueId);

      // Then
      expect(response, GetQagsFailedResponse(errorType: QagsErrorType.timeout));
    });

    test("when failure should return failed", () async {
      // Given
      dioAdapter.onGet(
        "/qags",
        (server) => server.reply(HttpStatus.notFound, {}),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQags(thematiqueId: thematiqueId);

      // Then
      expect(response, GetQagsFailedResponse());
    });
  });

  group("Fetch qags paginated", () {
    test("when success should return qags paginated", () async {
      // Given
      dioAdapter.onGet(
        "/qags/page/1",
        queryParameters: {
          "thematiqueId": thematiqueId,
          "filterType": "popular",
        },
        (server) => server.reply(
          HttpStatus.ok,
          {
            "maxPageNumber": 5,
            "qags": [
              {
                "qagId": "id1",
                "thematique": {"label": "Transports", "picto": "🚊"},
                "title": "title1",
                "username": "username1",
                "date": "2023-01-01",
                "support": {
                  "count": 116,
                  "isSupported": true,
                }
              },
            ],
          },
        ),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQagsPaginated(
        pageNumber: 1,
        thematiqueId: thematiqueId,
        filter: QagPaginatedFilter.popular,
      );

      // Then
      expect(
        response,
        GetQagsPaginatedSucceedResponse(
          maxPage: 5,
          paginatedQags: [
            QagPaginated(
              id: "id1",
              thematique: Thematique(picto: "🚊", label: "Transports"),
              title: "title1",
              username: "username1",
              date: DateTime(2023, 1, 1),
              supportCount: 116,
              isSupported: true,
            ),
          ],
        ),
      );
    });

    test("when failure should return failed", () async {
      // Given
      dioAdapter.onGet(
        "/qags/page/1",
        queryParameters: {
          "thematiqueId": thematiqueId,
          "filterType": "popular",
        },
        (server) => server.reply(HttpStatus.notFound, {}),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQagsPaginated(
        pageNumber: 1,
        thematiqueId: thematiqueId,
        filter: QagPaginatedFilter.popular,
      );

      // Then
      expect(response, GetQagsPaginatedFailedResponse());
    });
  });

  group("Fetch qag details", () {
    test("when success with support not null and response null should return qag details", () async {
      // Given
      dioAdapter.onGet(
        "/qags/$qagId",
        (server) => server.reply(
          HttpStatus.ok,
          {
            "id": "qagId",
            "thematique": {"label": "Transports", "picto": "🚊"},
            "title": "Titre de la QaG",
            "description": "Description textuelle",
            "date": "2024-01-23",
            "username": "Henri J.",
            "canShare": true,
            "support": {"count": 112, "isSupported": true},
            "response": null
          },
        ),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQagDetails(qagId: qagId);

      // Then
      expect(
        response,
        GetQagDetailsSucceedResponse(
          qagDetails: QagDetails(
            id: qagId,
            thematique: Thematique(picto: "🚊", label: "Transports"),
            title: "Titre de la QaG",
            description: "Description textuelle",
            date: DateTime(2024, 1, 23),
            username: "Henri J.",
            canShare: true,
            support: QagDetailsSupport(count: 112, isSupported: true),
            response: null,
          ),
        ),
      );
    });

    test("when success with support null and response not null should return qag details", () async {
      // Given
      dioAdapter.onGet(
        "/qags/$qagId",
        (server) => server.reply(
          HttpStatus.ok,
          {
            "id": "qagId",
            "thematique": {"label": "Transports", "picto": "🚊"},
            "title": "Titre de la QaG",
            "description": "Description textuelle",
            "date": "2024-01-23",
            "username": "Henri J.",
            "canShare": false,
            "support": null,
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
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQagDetails(qagId: qagId);

      // Then
      expect(
        response,
        GetQagDetailsSucceedResponse(
          qagDetails: QagDetails(
            id: qagId,
            thematique: Thematique(picto: "🚊", label: "Transports"),
            title: "Titre de la QaG",
            description: "Description textuelle",
            date: DateTime(2024, 1, 23),
            username: "Henri J.",
            canShare: false,
            support: null,
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

    test("when failure with 423 should return qag moderated failure", () async {
      // Given
      dioAdapter.onGet(
        "/qags/$qagId",
        (server) => server.reply(HttpStatus.locked, {}),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQagDetails(qagId: qagId);

      // Then
      expect(response, GetQagDetailsModerateFailedResponse());
    });

    test("when failure should return failed", () async {
      // Given
      dioAdapter.onGet(
        "/qags/$qagId",
        (server) => server.reply(HttpStatus.notFound, {}),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQagDetails(qagId: qagId);

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
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.supportQag(qagId: qagId);

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
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.supportQag(qagId: qagId);

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
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.deleteSupportQag(qagId: qagId);

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
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.deleteSupportQag(qagId: qagId);

      // Then
      expect(response, DeleteSupportQagFailedResponse());
    });
  });

  group("Give qag feedback", () {
    test("when success should return success", () async {
      // Given
      dioAdapter.onPost(
        "/qags/$qagId/feedback",
        (server) => server.reply(HttpStatus.ok, null),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
        data: {"isHelpful": true},
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.giveQagResponseFeedback(qagId: qagId, isHelpful: true);

      // Then
      expect(response, QagFeedbackSuccessResponse());
    });

    test("when failure should return failed", () async {
      // Given
      dioAdapter.onPost(
        "/qags/$qagId/feedback",
        (server) => server.reply(HttpStatus.notFound, {}),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
        data: {"isHelpful": true},
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.giveQagResponseFeedback(qagId: qagId, isHelpful: true);

      // Then
      expect(response, QagFeedbackFailedResponse());
    });
  });

  group("Fetch qag moderation list", () {
    test("when success should return qag moderation list", () async {
      // Given
      dioAdapter.onGet(
        "/moderate/qags",
        (server) => server.reply(
          HttpStatus.ok,
          {
            "totalNumber": 120,
            "qagsToModerate": [
              {
                "id": "qagId",
                "thematique": {"label": "Transports", "picto": "🚊"},
                "title": "Titre de la QaG",
                "description": "Description textuelle",
                "date": "2024-01-23",
                "username": "Henri J.",
                "support": {"count": 112, "isSupported": true},
              },
            ]
          },
        ),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQagModerationList();

      // Then
      expect(
        response,
        QagModerationListSuccessResponse(
          qagModerationList: QagModerationList(
            totalNumber: 120,
            qagsToModeration: [
              QagModeration(
                id: qagId,
                thematique: Thematique(picto: "🚊", label: "Transports"),
                title: "Titre de la QaG",
                description: "Description textuelle",
                date: DateTime(2024, 1, 23),
                username: "Henri J.",
                supportCount: 112,
                isSupported: true,
              ),
            ],
          ),
        ),
      );
    });

    test("when failure should return failed", () async {
      // Given
      dioAdapter.onGet(
        "/moderate/qags",
        (server) => server.reply(HttpStatus.notFound, {}),
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.fetchQagModerationList();

      // Then
      expect(response, QagModerationListFailedResponse());
    });
  });

  group("Moderate qag", () {
    test("when success should return success", () async {
      // Given
      dioAdapter.onPut(
        "/moderate/qags/$qagId",
        (server) => server.reply(HttpStatus.ok, {}),
        data: {
          "isAccepted": true,
        },
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.moderateQag(qagId: qagId, isAccepted: true);

      // Then
      expect(response, ModerateQagSuccessResponse());
    });

    test("when failure should return failed", () async {
      // Given
      dioAdapter.onPut(
        "/moderate/qags/$qagId",
        (server) => server.reply(HttpStatus.notFound, {}),
        data: {
          "isAccepted": true,
        },
        headers: {
          "accept": "application/json",
          "Authorization": "Bearer jwtToken",
        },
      );

      // When
      final repository = QagDioRepository(
        httpClient: httpClient,
        crashlyticsHelper: fakeCrashlyticsHelper,
      );
      final response = await repository.moderateQag(qagId: qagId, isAccepted: true);

      // Then
      expect(response, ModerateQagFailedResponse());
    });
  });
}
