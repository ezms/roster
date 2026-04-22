import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _scanned = false;
  bool _paused = false;
  int _seconds = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused) setState(() => _seconds++);
    });
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    _paused ? _scannerController.stop() : _scannerController.start();
  }

  void _stop() {
    Navigator.pop(context);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned || _paused) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    _scanned = true;
    _scannerController.stop();
    Navigator.pop(context, barcode!.rawValue!);
  }

  String get _chronometer {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer.cancel();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _togglePause,
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
                        valueColor: AlwaysStoppedAnimation<Color>(
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
    );
  }
}
