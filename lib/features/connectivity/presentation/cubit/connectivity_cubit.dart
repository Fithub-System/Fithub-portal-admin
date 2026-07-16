import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/connectivity_service.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit(this._service)
      : super(const ConnectivityState(isOnline: true));

  final ConnectivityService _service;

  Future<void> start() async {
    emit(ConnectivityState(isOnline: _service.isOnline));
    await _service.start();
    _service.onStatusChanged.listen((isOnline) {
      emit(ConnectivityState(isOnline: isOnline));
    });
  }
}

class ConnectivityState extends Equatable {
  const ConnectivityState({required this.isOnline});

  final bool isOnline;

  bool get isOffline => !isOnline;

  @override
  List<Object?> get props => [isOnline];
}
