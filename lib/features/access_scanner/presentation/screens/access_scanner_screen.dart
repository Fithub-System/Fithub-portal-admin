import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../config/theme/kinetic_tokens.dart';
import '../cubit/access_scanner_cubit.dart';
import '../cubit/access_scanner_state.dart';
import '../widgets/scan_success_banner.dart';
import '../widgets/scanner_target_overlay.dart';

/// Stitch **Access Scanner** (FEAT-01 §3)
/// Project: `13435235862240753621`
/// Screen id: verify via Stitch MCP `list_screens` — see [stitchScreenId].
class AccessScannerScreen extends StatefulWidget {
  const AccessScannerScreen({super.key});

  /// Stitch screen id — confirm via MCP when `GOOGLE_STITCH_API_KEY` is set.
  static const String stitchScreenId = KineticTokens.stitchAccessScannerScreenId;
  static const String stitchScreenTitle = 'Access Scanner';

  @override
  State<AccessScannerScreen> createState() => _AccessScannerScreenState();
}

class _AccessScannerScreenState extends State<AccessScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  final TextEditingController _manualPayloadController = TextEditingController();
  bool _useManualEntry = false;
  bool _cameraFallbackScheduled = false;

  @override
  void initState() {
    super.initState();
    // Sync after first frame — never from build / MobileScanner listeners.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccessScannerCubit>().onScannerOpened();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _manualPayloadController.dispose();
    super.dispose();
  }

  void _scheduleCameraFallback() {
    if (_cameraFallbackScheduled || _useManualEntry) return;
    _cameraFallbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _useManualEntry) return;
      setState(() => _useManualEntry = true);
    });
  }

  void _onBarcodeDetect(BuildContext context, BarcodeCapture capture) {
    // MobileScanner notifies from ValueListenableBuilder build paths on some
    // platforms — defer Cubit emits until after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<AccessScannerCubit>();
      cubit.markCameraReady();
      final value = capture.barcodes.firstOrNull?.rawValue;
      if (value == null) return;
      cubit.onQrDetected(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AccessScannerCubit, AccessScannerState>(
      listenWhen: (previous, current) =>
          current.success != null && current.success != previous.success,
      listener: (context, state) {
        final success = state.success;
        if (success == null) return;
        Future<void>.delayed(const Duration(seconds: 4), () {
          if (!context.mounted) return;
          context.read<AccessScannerCubit>().dismissSuccess();
        });
      },
      builder: (context, state) {
        return Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: KineticTokens.deepCharcoal,
                child: _useManualEntry
                    ? _ManualEntryPane(
                        controller: _manualPayloadController,
                        onSubmit: () => _submitManual(context),
                      )
                    : _CameraPane(
                        controller: _controller,
                        onDetect: (capture) => _onBarcodeDetect(context, capture),
                        onCameraError: _scheduleCameraFallback,
                      ),
              ),
            ),
            const Positioned.fill(child: ScannerTargetOverlay()),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.85,
                      colors: [
                        Colors.transparent,
                        KineticTokens.deepCharcoal.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 16,
              start: 24,
              end: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'access_scanner.title'.tr(),
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: KineticTokens.pureWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'access_scanner.subtitle'.tr(),
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: KineticTokens.zincGray,
                    ),
                  ),
                  if (state.rosterStatus == AccessScannerRosterStatus.syncing)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'access_scanner.roster.syncing'.tr(),
                        style: textTheme.bodySmall?.copyWith(
                          color: KineticTokens.electricLime,
                        ),
                      ),
                    ),
                  if (state.rosterStatus == AccessScannerRosterStatus.synced &&
                      state.rosterCount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'access_scanner.roster.synced'.tr(
                          namedArgs: {'count': '${state.rosterCount}'},
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          color: KineticTokens.electricLime,
                        ),
                      ),
                    ),
                  if (state.rosterStatus == AccessScannerRosterStatus.failed &&
                      state.rosterErrorKey != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.rosterErrorKey!.tr(),
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.orangeAccent,
                            ),
                          ),
                          if (state.rosterCount != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'access_scanner.roster.synced'.tr(
                                  namedArgs: {'count': '${state.rosterCount}'},
                                ),
                                style: textTheme.bodySmall?.copyWith(
                                  color: KineticTokens.zincGray,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                context.read<AccessScannerCubit>().syncRoster(),
                            style: TextButton.styleFrom(
                              foregroundColor: KineticTokens.electricLime,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('access_scanner.roster.retry'.tr()),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (state.isProcessing)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            if (state.success != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ScanSuccessBanner(
                  memberName: state.success!.memberName,
                  avatarUrl: state.success!.avatarUrl,
                  onDismiss: () =>
                      context.read<AccessScannerCubit>().dismissSuccess(),
                ),
              ),
            if (state.errorKey != null)
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Material(
                  color: const Color(0xFFB71C1C),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      state.errorKey!.tr(
                        namedArgs: {'reason': state.rejectReason ?? ''},
                      ),
                      style: const TextStyle(color: KineticTokens.pureWhite),
                    ),
                  ),
                ),
              ),
            if (kDebugMode || _useManualEntry)
              PositionedDirectional(
                end: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  heroTag: 'scanner-toggle-manual',
                  backgroundColor: KineticTokens.gunmetalCard,
                  onPressed: () =>
                      setState(() => _useManualEntry = !_useManualEntry),
                  child: Icon(
                    _useManualEntry ? Icons.camera_alt : Icons.keyboard,
                    color: KineticTokens.electricLime,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _submitManual(BuildContext context) {
    final payload = _manualPayloadController.text.trim();
    if (payload.isEmpty) return;
    context.read<AccessScannerCubit>().processManualPayload(payload);
  }
}

class _CameraPane extends StatelessWidget {
  const _CameraPane({
    required this.controller,
    required this.onDetect,
    required this.onCameraError,
  });

  final MobileScannerController controller;
  final void Function(BarcodeCapture capture) onDetect;
  final VoidCallback onCameraError;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller,
      onDetect: onDetect,
      errorBuilder: (context, error) {
        // Must not setState here — MobileScanner builds this inside
        // ValueListenableBuilder during its own build phase.
        onCameraError();
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'access_scanner.camera.unavailable'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: KineticTokens.zincGray),
            ),
          ),
        );
      },
    );
  }
}

class _ManualEntryPane extends StatelessWidget {
  const _ManualEntryPane({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'access_scanner.manual.title'.tr(),
                style: const TextStyle(
                  color: KineticTokens.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(color: KineticTokens.pureWhite),
                decoration: InputDecoration(
                  hintText: 'access_scanner.manual.hint'.tr(),
                  filled: true,
                  fillColor: KineticTokens.gunmetalCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: KineticTokens.zincGray),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: KineticTokens.electricLime,
                  foregroundColor: KineticTokens.deepCharcoal,
                ),
                child: Text('access_scanner.manual.submit'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
