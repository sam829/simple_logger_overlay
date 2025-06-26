import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../models/user_model.dart';
import '../error/failures.dart';
import 'dio_client.dart';

class ApiClient {
  final Dio dio = DioClient().dio;

  Future<Either<Failure, List<User>>> fetchUsers() async {
    try {
      final response = await dio.get('/users');
      final users = (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
      return Right(users);
    } on DioException catch (dioException) {
      if (dioException.type == DioExceptionType.connectionTimeout ||
          dioException.type == DioExceptionType.sendTimeout ||
          dioException.type == DioExceptionType.receiveTimeout) {
        return Left(NetworkFailure("Connection timeout"));
      } else if (dioException.response != null) {
        return Left(
          ServerFailure(
            "Server Error: ${dioException.response?.statusCode} ${dioException.response?.statusMessage}",
          ),
        );
      } else {
        return Left(UnknownFailure("Something went wrong"));
      }
    } catch (exception) {
      return Left(UnknownFailure("Unexpected Error $exception"));
    }
  }
}
