import 'package:flutter/material.dart';
import 'package:mobile/shared/repositories/attendance_repository.dart';

enum ScanStatus { success, alreadyRegistered, notFound, error }

class ScanFeedback {
  final ScanStatus status;
  final String message;

  const ScanFeedback({required this.status, required this.message});
}

class ScannerController extends ChangeNotifier {
  final AttendanceRepository _repository;
  final int classId;

  int? _sessionId;
  bool isInitializing = true;
  String? initError;
  ScanFeedback? feedback;
  bool _isProcessing = false;

  ScannerController({required this.classId, required AttendanceRepository repository})
      : _repository = repository {
    _init();
  }

  Future<void> _init() async {
    try {
      _sessionId = await _repository.openOrGetSession(classId);
    } catch (_) {
      initError = 'Falha ao abrir sessão de chamada';
    } finally {
      isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    isInitializing = true;
    initError = null;
    notifyListeners();
    await _init();
  }

  bool get ready => !isInitializing && initError == null;
  bool get isProcessing => _isProcessing;

  Future<void> processCode(String code) async {
    if (_isProcessing || _sessionId == null) return;
    _isProcessing = true;

    try {
      final studentName = await _repository.registerAttendance(code);
      feedback = ScanFeedback(status: ScanStatus.success, message: studentName);
    } on AlreadyRegisteredError {
      feedback = const ScanFeedback(
        status: ScanStatus.alreadyRegistered,
        message: 'Já registrado nesta chamada. Somente na próxima sessão.',
      );
    } on StudentNotFoundError {
      feedback = const ScanFeedback(status: ScanStatus.notFound, message: 'Aluno não encontrado');
    } on CommunicationError {
      feedback = const ScanFeedback(status: ScanStatus.error, message: 'Erro de comunicação, tente novamente');
    } catch (_) {
      feedback = const ScanFeedback(status: ScanStatus.error, message: 'Erro de comunicação, tente novamente');
    }

    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    feedback = null;
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> closeSession() async {
    if (_sessionId != null) {
      await _repository.closeSession(_sessionId!);
    }
  }
}
