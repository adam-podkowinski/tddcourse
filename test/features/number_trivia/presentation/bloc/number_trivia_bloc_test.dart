import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart' as Mocktail;
import 'package:tddcource/core/error/failures.dart';
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

  NumberTriviaBloc getBloc() => NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter,
      );

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = getBloc();
    Mocktail.registerFallbackValue(Params(number: 1));
  });

  test('initial state should be Empty', () {
    expect(bloc.state, Empty());
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'Test text', number: 1);

    void setUpMockInputConverterSuccess() => Mocktail.when(
          () => mockInputConverter.stringToUnsignedInteger(Mocktail.any()),
        ).thenReturn(Right(tNumberParsed));
    void setUpMockInputConverterFailure() => Mocktail.when(
          () => mockInputConverter.stringToUnsignedInteger(Mocktail.any()),
        ).thenReturn(Left(InvalidInputFailure()));
    void setUpGetConcreteNumberTriviaSuccess() => Mocktail.when(
          () => mockGetConcreteNumberTrivia(Mocktail.any()),
        ).thenAnswer((_) async => Right(tNumberTrivia));

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        setUpMockInputConverterSuccess();
        setUpGetConcreteNumberTriviaSuccess();

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await Mocktail.untilCalled(
          () => mockInputConverter.stringToUnsignedInteger(Mocktail.any()),
        );

        Mocktail.verify(
            () => mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    blocTest(
      'should emit [Error] when the input is invalid',
      build: () {
        setUpMockInputConverterFailure();

        return getBloc();
      },
      act: (NumberTriviaBloc tBloc) => tBloc.add(
        GetTriviaForConcreteNumber(tNumberString),
      ),
      expect: () => [Error(message: INVALID_INPUT_FAILURE_MESSAGE)],
    );

    test(
      'should get data from the concrete use case when input is correct',
      () async {
        setUpMockInputConverterSuccess();
        setUpGetConcreteNumberTriviaSuccess();

        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await Mocktail.untilCalled(
          () => mockGetConcreteNumberTrivia(Mocktail.any()),
        );

        Mocktail.verify(
          () => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)),
        );
      },
    );

    blocTest(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        setUpMockInputConverterSuccess();
        setUpGetConcreteNumberTriviaSuccess();
        return getBloc();
      },
      act: (NumberTriviaBloc tBloc) {
        tBloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
      expect: () {
        return [Loading(), Loaded(trivia: tNumberTrivia)];
      },
    );

    blocTest(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        setUpMockInputConverterSuccess();
        Mocktail.when(
          () => mockGetConcreteNumberTrivia(Mocktail.any()),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return getBloc();
      },
      act: (NumberTriviaBloc tBloc) {
        tBloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
      expect: () {
        return [Loading(), Error(message: SERVER_FAILURE_MESSAGE)];
      },
    );

    blocTest(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      build: () {
        setUpMockInputConverterSuccess();
        Mocktail.when(
          () => mockGetConcreteNumberTrivia(Mocktail.any()),
        ).thenAnswer((_) async => Left(CacheFailure()));
        return getBloc();
      },
      act: (NumberTriviaBloc tBloc) {
        tBloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
      expect: () {
        return [Loading(), Error(message: CACHE_FAILURE_MESSAGE)];
      },
    );
  });
}
