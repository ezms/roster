import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile/features/scanner/scanner_controller.dart';
import 'package:mobile/shared/repositories/attendance_repository.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  final int classId;

  const ScannerScreen({super.key, required this.classId});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  late final ScannerController _controller;

  bool _paused = false;
  int _seconds = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = ScannerController(
      classId: widget.classId,
      repository: AttendanceRepository(),
    );
    _controller.addListener(_onControllerUpdate);
    _startTimer();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused && _controller.ready && mounted) setState(() => _seconds++);
    });
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    _paused ? _scannerController.stop() : _scannerController.start();
  }

  Future<void> _stop() async {
    _timer.cancel();
    _scannerController.stop();
    await _controller.closeSession();
    if (mounted) Navigator.pop(context);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_paused || _controller.isProcessing || !_controller.ready) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    _controller.processCode(barcode!.rawValue!);
  }

  String get _chronometer {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _controller.isInitializing
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _controller.initError != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  _controller.initError!,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                                    ),
                                    const SizedBox(width: 16),
                                    FilledButton(
                                      onPressed: _controller.retry,
                                      child: const Text('Tentar novamente'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        : MobileScanner(
                            controller: _scannerController,
                            onDetect: _onDetect,
                          ),
              ),
              if (_controller.initError == null)
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _controller.isInitializing ? null : _togglePause,
                      icon: Icon(
                        _paused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: (_seconds % 60) / 60,
                            strokeWidth: 4,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                          Text(
                            _chronometer,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _stop,
                      icon: const Icon(
                        Icons.stop,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_controller.feedback != null)
            Positioned(
              bottom: 110,
              left: 24,
              right: 24,
              child: _ScanFeedbackBanner(feedback: _controller.feedback!),
            ),
        ],
      ),
    );
  }
}

class _ScanFeedbackBanner extends StatelessWidget {
  final ScanFeedback feedback;

  const _ScanFeedbackBanner({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (feedback.status) {
      ScanStatus.success => (Icons.check_circle, Colors.green),
      ScanStatus.alreadyRegistered => (Icons.warning_amber_rounded, Colors.orange),
      ScanStatus.notFound || ScanStatus.error => (Icons.cancel, Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feedback.message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
