import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// FEAT-97 scanner input path. Default **hybrid**.
enum ScannerInputMode { hardwareGun, webcam, hybrid }

extension ScannerInputModeCodec on ScannerInputMode {
  String get wire => switch (this) {
    ScannerInputMode.hardwareGun => 'hardware_gun',
    ScannerInputMode.webcam => 'webcam',
    ScannerInputMode.hybrid => 'hybrid',
  };

  static ScannerInputMode parse(String? raw) {
    return switch (raw) {
      'hardware_gun' => ScannerInputMode.hardwareGun,
      'webcam' => ScannerInputMode.webcam,
      _ => ScannerInputMode.hybrid,
    };
  }
}

class ScannerInputState extends Equatable {
  const ScannerInputState({
    this.mode = ScannerInputMode.hybrid,
    this.draft = ScannerInputMode.hybrid,
    this.saving = false,
    this.gunSessionPausedCamera = false,
    this.canWrite = true,
  });

  final ScannerInputMode mode;
  final ScannerInputMode draft;
  final bool saving;
  final bool gunSessionPausedCamera;
  final bool canWrite;

  bool get cameraMounted => switch (mode) {
    ScannerInputMode.hardwareGun => false,
    ScannerInputMode.webcam => true,
    ScannerInputMode.hybrid => !gunSessionPausedCamera,
  };

  bool get hidMounted => switch (mode) {
    ScannerInputMode.hardwareGun => true,
    ScannerInputMode.webcam => false,
    ScannerInputMode.hybrid => true,
  };

  ScannerInputState copyWith({
    ScannerInputMode? mode,
    ScannerInputMode? draft,
    bool? saving,
    bool? gunSessionPausedCamera,
    bool? canWrite,
  }) {
    return ScannerInputState(
      mode: mode ?? this.mode,
      draft: draft ?? this.draft,
      saving: saving ?? this.saving,
      gunSessionPausedCamera:
          gunSessionPausedCamera ?? this.gunSessionPausedCamera,
      canWrite: canWrite ?? this.canWrite,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    draft,
    saving,
    gunSessionPausedCamera,
    canWrite,
  ];
}

class ScannerInputCubit extends Cubit<ScannerInputState> {
  ScannerInputCubit({
    this.canWrite = true,
    SharedPreferences? prefs,
    SupabaseClient? client,
  }) : _prefs = prefs,
       _client = client,
       super(ScannerInputState(canWrite: canWrite));

  static const prefsKey = 'scanner_input_mode';

  final bool canWrite;
  final SharedPreferences? _prefs;
  final SupabaseClient? _client;

  Future<void> load() async {
    var mode = ScannerInputMode.hybrid;
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      mode = ScannerInputModeCodec.parse(prefs.getString(prefsKey));
    } catch (_) {}
    try {
      final client = _client ?? Supabase.instance.client;
      final raw = await client.rpc('get_scanner_input_mode');
      if (raw is String) mode = ScannerInputModeCodec.parse(raw);
      if (raw is Map && raw['scanner_input_mode'] != null) {
        mode = ScannerInputModeCodec.parse('${raw['scanner_input_mode']}');
      }
    } catch (_) {}
    emit(
      state.copyWith(
        mode: mode,
        draft: mode,
        canWrite: canWrite,
        gunSessionPausedCamera: false,
      ),
    );
  }

  void selectDraft(ScannerInputMode mode) {
    if (!state.canWrite) return;
    emit(state.copyWith(draft: mode));
  }

  Future<void> save() async {
    if (!state.canWrite) return;
    emit(state.copyWith(saving: true));
    final mode = state.draft;
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, mode.wire);
    } catch (_) {}
    try {
      final client = _client ?? Supabase.instance.client;
      await client.rpc('set_scanner_input_mode', params: {'p_mode': mode.wire});
    } catch (_) {}
    emit(
      state.copyWith(mode: mode, saving: false, gunSessionPausedCamera: false),
    );
  }

  void pauseCameraAfterGunBurst() {
    if (state.mode != ScannerInputMode.hybrid) return;
    emit(state.copyWith(gunSessionPausedCamera: true));
  }

  void resumeCamera() {
    emit(state.copyWith(gunSessionPausedCamera: false));
  }
}
