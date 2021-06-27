import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tddcource/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tddcource/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test text');

  test(
    'should be a subclass of NumberTrivia entity',
    () async {
      //assert
      expect(tNumberTriviaModel, isA<NumberTrivia>());
    },
  );

  group('fromJson', () {
    test(
      'should return a valid model when the JSON number is an integer',
      () async {
        final Map<String, dynamic> jsonMap = jsonDecode(fixture('trivia.json'));
        final result = NumberTriviaModel.fromJSON(jsonMap);
        expect(result, tNumberTriviaModel);
      },
    );

    test(
      'should return a valid model when the JSON number is regarded as a double',
      () async {
        final Map<String, dynamic> jsonMap = jsonDecode(
          fixture('trivia_double.json'),
        );
        final result = NumberTriviaModel.fromJSON(jsonMap);
        expect(result, tNumberTriviaModel);
      },
    );
  });

  group('toJson', () {
    test(
      'should return a JSON map containing the proper data',
      () {
        final result = tNumberTriviaModel.toJson();
        final expectedMap = {'text': 'Test text', 'number': 1};
        expect(result, expectedMap);
      },
    );
  });
}
