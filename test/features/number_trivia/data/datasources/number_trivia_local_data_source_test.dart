import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tddcource/core/error/exceptions.dart';
import 'package:tddcource/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tddcource/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJSON(
      jsonDecode(
        fixture('trivia_cached.json'),
      ),
    );

    test(
      'should return NumberTriviaModel from SharedPreferences when there is one in the cache',
      () async {
        when(mockSharedPreferences.getString(any)).thenReturn(
          fixture('trivia_cached.json'),
        );

        final result = await dataSource.getLastNumberTrivia();

        verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a CacheException when there is not a cached value',
      () async {
        when(mockSharedPreferences.getString(any)).thenReturn(null);

        final call = dataSource.getLastNumberTrivia;

        expect(() => call(), throwsA(TypeMatcher<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'Text trivia');
    test(
      'should call SharedPreferences to cache the data',
      () async {
        when(mockSharedPreferences.setString(any, any)).thenAnswer((_) => Future.value(true));

        await dataSource.cacheNumberTrivia(tNumberTriviaModel);

        final expectedJsonString = jsonEncode(tNumberTriviaModel.toJson());
        verify(
          mockSharedPreferences.setString(
            CACHED_NUMBER_TRIVIA,
            expectedJsonString,
          ),
        );
      },
    );
  });
}
