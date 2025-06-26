import 'package:dartz/dartz.dart';

import '../core/error/failures.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient apiClient;
  UserRepository(this.apiClient);

  Future<Either<Failure, List<User>>> getUsers() {
    return apiClient.fetchUsers();
  }
}
