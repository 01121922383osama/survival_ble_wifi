import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/features/sensor_connectivity/domain/entities/sensor_entities.dart';
import 'package:survival/features/sensor_connectivity/domain/repositories/sensor_repository.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_state.dart';

class SensorCubit extends Cubit<SensorState> {
  final SensorRepository _sensorRepository;
  StreamSubscription<List<SensorDevice>>? _deviceSubscription;
  // Keep track of individual device data subscriptions if needed
  // Map<String, StreamSubscription<SensorData>> _dataSubscriptions = {};

  SensorCubit(this._sensorRepository) : super(SensorInitial());

  // --- Firestore Device Streaming ---
  void startStreamingDevices() {
    emit(SensorLoading());
    _deviceSubscription?.cancel(); // Cancel previous subscription
    _deviceSubscription = _sensorRepository.streamFirestoreDevices().listen(
      (devices) {
        emit(SensorLoaded(devices));
      },
      onError: (error) {
        emit(
          SensorError(
            _mapFailureToMessage(
              error is Failure ? error : DatabaseFailure(error.toString()),
            ),
          ),
        );
      },
    );
  }

  // --- BLE Scanning (Keep for potential future use or initial pairing) ---
  Future<void> scanForDevices() async {
    // This might be less relevant now devices are primarily from Firestore
    // Consider if BLE scan is still needed for discovery/pairing
    emit(SensorLoading());
    try {
      // Placeholder: Maybe trigger a BLE scan and reconcile with Firestore?
      // For now, just reload Firestore stream
      startStreamingDevices();
    } catch (e) {
      emit(SensorError('Failed to scan for devices: ${e.toString()}'));
    }
  }

  // --- Device Actions (Connect/Disconnect via BLE - Keep if needed) ---
  Future<void> connectToDevice(String deviceId) async {
    emit(SensorLoading());
    final result = await _sensorRepository.connectToDevice(deviceId);
    result.fold((failure) => emit(SensorError(_mapFailureToMessage(failure))), (
      success,
    ) {
      if (success) {
        // Maybe update Firestore status here?
        // Reload devices or update specific device state
        startStreamingDevices();
      } else {
        emit(SensorError('Failed to connect to device $deviceId'));
      }
    });
  }

  Future<void> disconnectFromDevice(String deviceId) async {
    emit(SensorLoading());
    final result = await _sensorRepository.disconnectFromDevice(deviceId);
    result.fold((failure) => emit(SensorError(_mapFailureToMessage(failure))), (
      _,
    ) {
      // Maybe update Firestore status here?
      // Reload devices or update specific device state
      startStreamingDevices();
    });
  }

  // --- Update Device Settings (e.g., Notification Toggle) ---
  Future<void> updateDeviceNotificationSetting(
    String deviceId,
    bool enabled,
  ) async {
    // Optimistic UI update (optional)
    if (state is SensorLoaded) {
      final currentDevices = (state as SensorLoaded).sensors;
      final updatedDevices = currentDevices.map((device) {
        if (device.id == deviceId) {
          return device.copyWith(notificationsEnabled: enabled);
        }
        return device;
      }).toList();
      emit(SensorLoaded(updatedDevices));
    }

    final result = await _sensorRepository.updateDeviceSettingsInFirestore(
      deviceId,
      {'notificationsEnabled': enabled},
    );
    result.fold(
      (failure) {
        // Revert optimistic update on failure
        startStreamingDevices(); // Reload to get actual state
        emit(
          SensorError(
            'Failed to update notification setting: ${_mapFailureToMessage(failure)}',
          ),
        );
      },
      (_) {
        // Firestore stream will update the state automatically, no need to emit here unless not using optimistic update
      },
    );
  }

  // --- Stop Alert Action ---
  Future<void> stopDeviceAlert(String deviceId) async {
    // Optimistic UI update (optional)
    if (state is SensorLoaded) {
      final currentDevices = (state as SensorLoaded).sensors;
      final updatedDevices = currentDevices.map((device) {
        if (device.id == deviceId) {
          // Reset alert status locally
          return device.copyWith(
            status: DeviceStatus.online,
          ); // Or appropriate non-alert status
        }
        return device;
      }).toList();
      emit(SensorLoaded(updatedDevices));
    }

    // Update status in Firestore to a non-alert state
    final result = await _sensorRepository.updateDeviceStatusInFirestore(
      deviceId,
      {
        'status': DeviceStatus.online.toString().split('.').last,
      }, // Set to 'online' or similar
    );
    result.fold(
      (failure) {
        // Revert optimistic update on failure
        startStreamingDevices(); // Reload to get actual state
        emit(
          SensorError('Failed to stop alert: ${_mapFailureToMessage(failure)}'),
        );
      },
      (_) {
        // Firestore stream will update the state automatically
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        return (failure as ServerFailure).message;
      case const (ConnectionFailure):
        return (failure as ConnectionFailure).message;
      case const (CommunicationFailure):
        return (failure as CommunicationFailure).message;
      case const (DatabaseFailure):
        return (failure as DatabaseFailure).message;
      default:
        return 'An unexpected error occurred';
    }
  }

  @override
  Future<void> close() {
    _deviceSubscription?.cancel();
    // Cancel individual data subscriptions if used
    // _dataSubscriptions.values.forEach((sub) => sub.cancel());
    return super.close();
  }
}
