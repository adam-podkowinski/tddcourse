import 'package:dartz/dartz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tddcource/core/error/exceptions.dart';
import 'package:tddcource/core/error/failures.dart';
import 'package:tddcource/core/platform/network_info.dart';
import 'package:tddcource/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tddcource/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tddcource/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tddcource/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tddcource/features/number_trivia/domain/entities/number_trivia.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateMocks(
  [NumberTriviaRemoteDataSource, NumberTriviaLocalDataSource, NetworkInfo],
)
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(
      text: 'Test text',
      number: tNumber,
    );
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should check if the device is online',
      () async {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);

        await repository.getConcreteNumberTrivia(tNumber);

        verify(mockNetworkInfo.isConnected);
      },
    );

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);

          await repository.getConcreteNumberTrivia(tNumber);

          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenThrow(ServerException());

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
    });
  });
}
