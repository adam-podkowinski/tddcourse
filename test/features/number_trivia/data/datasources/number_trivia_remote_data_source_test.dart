import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart' as Mocktail;
import 'package:http/http.dart' as http;
import 'package:tddcource/core/error/exceptions.dart';
import 'package:tddcource/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tddcource/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mocktail.Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
    Mocktail.registerFallbackValue(Uri());
  });

  void setUpMockHttpClientSuccess200() {
    Mocktail.when(
      () => mockHttpClient.get(
        Mocktail.any(),
        headers: Mocktail.any(named: 'headers'),
      ),
    ).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientSuccess404() {
    Mocktail.when(
      () => mockHttpClient.get(
        Mocktail.any(),
        headers: Mocktail.any(named: 'headers'),
      ),
    ).thenAnswer((_) async => http.Response(fixture('trivia.json'), 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      jsonDecode(
        fixture('trivia.json'),
      ),
    );

    test(
      '''should perform a GET request on a URL with number
       being the endpoint and with application/json header''',
      () async {
        setUpMockHttpClientSuccess200();

        dataSource.getConcreteNumberTrivia(tNumber);

        Mocktail.verify(
          () => mockHttpClient.get(
            Uri.parse('http://numbersapi.com/$tNumber'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      'should return NumberTrivia when the response code is 200',
      () async {
        setUpMockHttpClientSuccess200();

        final result = await dataSource.getConcreteNumberTrivia(tNumber);

        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        setUpMockHttpClientSuccess404();

        final call = dataSource.getConcreteNumberTrivia;

        expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      jsonDecode(
        fixture('trivia.json'),
      ),
    );

    test(
      '''should perform a GET request on a URL with number
       being the endpoint and with application/json header''',
      () async {
        setUpMockHttpClientSuccess200();

        dataSource.getRandomNumberTrivia();

        Mocktail.verify(
          () => mockHttpClient.get(
            Uri.parse('http://numbersapi.com/random'),
            headers: {'Content-Type': 'application/json'},
          ),
        );
      },
    );

    test(
      'should return NumberTrivia when the response code is 200',
      () async {
        setUpMockHttpClientSuccess200();

        final result = await dataSource.getRandomNumberTrivia();

        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        setUpMockHttpClientSuccess404();

        final call = dataSource.getRandomNumberTrivia;

        expect(() => call(), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });
}
