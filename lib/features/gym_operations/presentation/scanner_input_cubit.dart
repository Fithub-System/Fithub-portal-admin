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
    this.saveError,
  });

  final ScannerInputMode mode;
  final ScannerInputMode draft;
  final bool saving;
  final bool gunSessionPausedCamera;
  final bool canWrite;
  final String? saveError;

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
    String? saveError,
    bool clearSaveError = false,
  }) {
    return ScannerInputState(
      mode: mode ?? this.mode,
      draft: draft ?? this.draft,
      saving: saving ?? this.saving,
      gunSessionPausedCamera:
          gunSessionPausedCamera ?? this.gunSessionPausedCamera,
      canWrite: canWrite ?? this.canWrite,
      saveError: clearSaveError ? null : (saveError ?? this.saveError),
    );
  }

  @override
  List<Object?> get props => [
    mode,
    draft,
    saving,
    gunSessionPausedCamera,
    canWrite,
    saveError,
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
    } catch (_) {
      // Prefs miss is offline-safe; RPC is source of truth when reachable.
    }
    try {
      final client = _client ?? Supabase.instance.client;
      final raw = await client.rpc('get_scanner_input_mode');
      final parsed = _parseMode(raw);
      if (parsed != null) mode = parsed;
    } catch (_) {
      // Offline: keep SharedPreferences / default hybrid (AC-E2).
    }
    emit(
      state.copyWith(
        mode: mode,
        draft: mode,
        canWrite: canWrite,
        gunSessionPausedCamera: false,
        clearSaveError: true,
      ),
    );
  }

  void selectDraft(ScannerInputMode mode) {
    if (!state.canWrite) return;
    emit(state.copyWith(draft: mode));
  }

  Future<void> save() async {
    if (!state.canWrite) return;
    emit(state.copyWith(saving: true, clearSaveError: true));
    final mode = state.draft;
    try {
      final client = _client ?? Supabase.instance.client;
      await client.rpc('set_scanner_input_mode', params: {'p_mode': mode.wire});
    } on Object catch (error) {
      emit(state.copyWith(saving: false, saveError: _saveErrorMessage(error)));
      return;
    }
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, mode.wire);
    } catch (_) {
      // RPC already persisted; local cache is best-effort.
    }
    emit(
      state.copyWith(
        mode: mode,
        saving: false,
        gunSessionPausedCamera: false,
        clearSaveError: true,
      ),
    );
  }

  static ScannerInputMode? _parseMode(dynamic raw) {
    if (raw is String) return ScannerInputModeCodec.parse(raw);
    if (raw is Map) {
      final mode = raw['mode'] ?? raw['scanner_input_mode'];
      if (mode != null) return ScannerInputModeCodec.parse('$mode');
    }
    return null;
  }

  static String _saveErrorMessage(Object error) {
    final hay = error.toString().toLowerCase();
    if (hay.contains('feat97_admin_only') || hay.contains('42501')) {
      return 'settings.operations.save_denied';
    }
    return 'settings.operations.save_failed';
  }

  void pauseCameraAfterGunBurst() {
    if (state.mode != ScannerInputMode.hybrid) return;
    emit(state.copyWith(gunSessionPausedCamera: true));
  }

  void resumeCamera() {
    emit(state.copyWith(gunSessionPausedCamera: false));
  }
}
