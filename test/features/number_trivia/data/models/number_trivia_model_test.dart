import 'package:flutter_test/flutter_test.dart';
import 'package:tddcource/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tddcource/features/number_trivia/domain/entities/number_trivia.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test text');

  test(
    'should be a subclass of NumberTrivia entity',
    () async {
      //assert
      expect(tNumberTriviaModel, isA<NumberTrivia>());
    },
  );
}
