import 'package:dartz/dartz.dart';
import '../repositories/memberships_repository.dart';


class MembershipsUseCase {
  final MembershipsRepository repository;

  MembershipsUseCase(this.repository);

  Future<Either<Exception, Unit>> call() async {
    return await repository.callApi();
  }
}

