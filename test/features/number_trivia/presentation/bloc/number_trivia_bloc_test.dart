import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart' as Mocktail;
import 'package:tddcource/core/util/input_converter.dart';
import 'package:tddcource/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tddcource/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tddcource/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tddcource/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mocktail.Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mocktail.Mock
    implements GetRandomNumberTrivia {}

class MockInputConverter extends Mocktail.Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initial state should be Empty', () {
    expect(bloc.state, Empty());
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'Test text', number: 1);

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        Mocktail.when(
          () => mockInputConverter.stringToUnsignedInteger(Mocktail.any()),
        ).thenReturn(Right(tNumberParsed));

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await Mocktail.untilCalled(
            () => mockInputConverter.stringToUnsignedInteger(Mocktail.any()));

        Mocktail.verify(
            () => mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    blocTest(
      'emits [Error] when the input is invalid',
      build: () {
        Mocktail.when(
          () => mockInputConverter.stringToUnsignedInteger(Mocktail.any()),
        ).thenReturn(Left(InvalidInputFailure()));

        return NumberTriviaBloc(
          getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
          getRandomNumberTrivia: mockGetRandomNumberTrivia,
          inputConverter: mockInputConverter,
        );
      },
      act: (NumberTriviaBloc tBloc) => tBloc.add(
        GetTriviaForConcreteNumber(tNumberString),
      ),
      expect: () => [Error(message: INVALID_INPUT_FAILURE_MESSAGE)],
    );
  });
}
