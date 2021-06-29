import 'package:dartz/dartz.dart';
import 'package:tddcource/core/error/failures.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    final result = int.tryParse(str);
    if (result == null || result < 0) {
      return Left(InvalidInputFailure());
    } else {
      return Right(int.parse(str));
    }
  }
}

class InvalidInputFailure extends Failure {}
