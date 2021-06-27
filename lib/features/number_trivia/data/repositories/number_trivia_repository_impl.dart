import 'package:dartz/dartz.dart';
import 'package:tddcource/core/error/exceptions.dart';
import 'package:tddcource/core/error/failures.dart';
import 'package:tddcource/core/platform/network_info.dart';
import 'package:tddcource/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tddcource/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tddcource/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tddcource/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
    int number,
  ) async {
    networkInfo.isConnected;
    try {
      final remoteTrivia =
          await remoteDataSource.getConcreteNumberTrivia(number);
      await localDataSource.cacheNumberTrivia(remoteTrivia);
      return Right(remoteTrivia);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    // TODO: implement getRandomNumberTrivia
    return Right(NumberTrivia(number: 1, text: ''));
  }
}
