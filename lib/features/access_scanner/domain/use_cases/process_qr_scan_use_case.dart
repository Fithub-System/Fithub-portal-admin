import '../../../scan/data/repositories/scan_repository.dart';

/// Offline QR scan branch — reuses [ScanRepository] (FEAT-01 AC2).
class ProcessQrScanUseCase {
  const ProcessQrScanUseCase(this._scanRepository);

  final ScanRepository _scanRepository;

  Future<ScanProcessResult> call({
    required String tenantId,
    required String rawPayload,
  }) {
    return _scanRepository.processOfflineScan(
      tenantId: tenantId,
      rawPayload: rawPayload,
    );
  }
}
