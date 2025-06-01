import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:survival/features/home/presentation/widgets/device_card.dart'; // Reusing the existing DeviceCard
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_cubit.dart';
import 'package:survival/features/sensor_connectivity/presentation/cubit/sensor_state.dart';

class ViewAllDevicesPage extends StatelessWidget {
  const ViewAllDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View All Devices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<SensorCubit, SensorState>(
        builder: (context, state) {
          if (state is SensorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SensorError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading devices: ${state.message}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          } else if (state is SensorLoaded) {
            if (state.sensors.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No devices found. Add a new device from the Manage tab.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            // Display the list of devices using DeviceCard
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.sensors.length,
              itemBuilder: (context, index) {
                final sensor = state.sensors[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: DeviceCard(
                    sensor: sensor,
                    onTap: () {
                      // Navigate to DeviceDetailsPage with the device ID
                      context.push('/devices/${sensor.id}');
                    },
                  ),
                );
              },
            );
          } else {
            // Initial state or unexpected state
            return const Center(child: Text('Loading devices...'));
          }
        },
      ),
    );
  }
}
