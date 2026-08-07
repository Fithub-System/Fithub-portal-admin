/// Gates cloud-required mutations while SafeMode / offline (FEAT-26).
///
/// Presentation must never treat offline cloud writes as silent success.
class CloudMutationGuard {
  const CloudMutationGuard({required bool Function() isOnline})
    : _isOnline = isOnline;

  final bool Function() _isOnline;

  bool get isOnline => _isOnline();

  /// Shared EasyLocalization key for deny/defer copy (EN|AR).
  static const String deniedMessageKey = 'connectivity.cloud_required.denied';
}
