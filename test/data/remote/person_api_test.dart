// test/data/remote/person_api_test.dart
//
// Covers HttpPersonApi — the client wrapper over the backend's
// /api/person/{id} bio endpoint and /api/person/{id}/credits filmography
// endpoint (Pass 3 CAST-2). Mocks Dio directly because the credits
// response is a JSON list.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/api_client.dart';
import 'package:streamload_client/data/remote/endpoints/person_api.dart';

class _DioMock extends Mock implements Dio {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  test('get(personId) parses the bio response', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>('/api/person/287'))
        .thenAnswer((_) async => Response<dynamic>(
              requestOptions: RequestOptions(path: '/api/person/287'),
              statusCode: 200,
              data: {
                'tmdb_id': 287,
                'name': 'Brad Pitt',
                'biography': 'American actor.',
                'birthday': '1963-12-18',
                'deathday': null,
                'place_of_birth': 'Shawnee, Oklahoma, USA',
                'profile_url': 'https://img/profile.jpg',
                'also_known_as': ['Brad', 'Pitt'],
                'known_for_department': 'Acting',
              },
            ));

    final api = HttpPersonApi(ApiClient.test(dio));
    final person = await api.get(287);
    expect(person.tmdbId, 287);
    expect(person.name, 'Brad Pitt');
    expect(person.biography, 'American actor.');
    expect(person.birthday, '1963-12-18');
    expect(person.deathday, isNull);
    expect(person.placeOfBirth, 'Shawnee, Oklahoma, USA');
    expect(person.profileUrl, 'https://img/profile.jpg');
    expect(person.alsoKnownAs, ['Brad', 'Pitt']);
    expect(person.knownForDepartment, 'Acting');
  });

  test('get(personId) handles missing optional fields', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>('/api/person/1'))
        .thenAnswer((_) async => Response<dynamic>(
              requestOptions: RequestOptions(path: '/api/person/1'),
              statusCode: 200,
              data: {
                'tmdb_id': 1,
                'name': 'Anon',
                'also_known_as': <String>[],
              },
            ));

    final api = HttpPersonApi(ApiClient.test(dio));
    final person = await api.get(1);
    expect(person.name, 'Anon');
    expect(person.biography, isNull);
    expect(person.profileUrl, isNull);
    expect(person.alsoKnownAs, isEmpty);
  });

  test('credits(personId) parses the filmography list', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>('/api/person/287/credits'))
        .thenAnswer((_) async => Response<dynamic>(
              requestOptions: RequestOptions(path: '/api/person/287/credits'),
              statusCode: 200,
              data: [
                {
                  'tmdb_id': 20,
                  'media_type': 'movie',
                  'title': 'Blockbuster',
                  'year': 2020,
                  'poster_url': 'https://img/p20.jpg',
                  'backdrop_url': null,
                  'character': 'Hero',
                },
                {
                  'tmdb_id': 30,
                  'media_type': 'tv',
                  'title': 'The Show',
                  'year': 2015,
                  'poster_url': 'https://img/p30.jpg',
                  'backdrop_url': null,
                  'character': 'Lead',
                },
              ],
            ));

    final api = HttpPersonApi(ApiClient.test(dio));
    final credits = await api.credits(287);
    expect(credits, hasLength(2));
    expect(credits[0].tmdbId, 20);
    expect(credits[0].title, 'Blockbuster');
    expect(credits[0].year, 2020);
    expect(credits[0].mediaType, 'movie');
    expect(credits[1].mediaType, 'tv');
  });

  test('credits() returns empty list when body is null', () async {
    final dio = _DioMock();
    when(() => dio.get<dynamic>('/api/person/9/credits'))
        .thenAnswer((_) async => Response<dynamic>(
              requestOptions: RequestOptions(path: '/api/person/9/credits'),
              statusCode: 200,
              data: null,
            ));

    final api = HttpPersonApi(ApiClient.test(dio));
    final credits = await api.credits(9);
    expect(credits, isEmpty);
  });
}
