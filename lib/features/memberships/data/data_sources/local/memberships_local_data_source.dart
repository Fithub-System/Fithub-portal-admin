import 'package:dartz/dartz.dart';


abstract class MembershipsLocalDataSource {
  Future<Unit> getFromLocalDataBase();
}

class MembershipsLocalDataSourceImpl implements MembershipsLocalDataSource {
  MembershipsLocalDataSourceImpl();

  @override
  Future<Unit> getFromLocalDataBase() async {
    // send api request here
    return Future.value(unit);
  }

}
  