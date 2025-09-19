import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

// NFC状態の定義
abstract class NfcState extends Equatable {
  const NfcState();

  @override
  List<Object?> get props => [];
}

class NfcInitial extends NfcState {}

class NfcScanning extends NfcState {}

class NfcDetected extends NfcState {
  final String data;

  const NfcDetected(this.data);

  @override
  List<Object?> get props => [data];
}

class NfcError extends NfcState {
  final String message;

  const NfcError(this.message);

  @override
  List<Object?> get props => [message];
}

class NfcWriting extends NfcState {}

class NfcWritten extends NfcState {}

// NFCプロバイダー
final nfcProvider = StateNotifierProvider<NfcNotifier, NfcState>((ref) {
  return NfcNotifier();
});

class NfcNotifier extends StateNotifier<NfcState> {
  NfcNotifier() : super(NfcInitial());

  void startScanning() {
    state = NfcScanning();
  }

  void onNfcDetected(String data) {
    state = NfcDetected(data);
  }

  void onNfcError(String message) {
    state = NfcError(message);
  }

  void startWriting() {
    state = NfcWriting();
  }

  void onNfcWritten() {
    state = NfcWritten();
  }

  void reset() {
    state = NfcInitial();
  }
}

