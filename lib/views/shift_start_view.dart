import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location_tracker/services/location_service.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:go_router/go_router.dart';
import 'package:location_tracker/view_models/shift_start_view_model.dart';
import 'package:location_tracker/providers/location_provider.dart';

class ShiftStartView extends ConsumerStatefulWidget {
  const ShiftStartView({super.key});

  @override
  ConsumerState<ShiftStartView> createState() => _ShiftStartViewState();
}

class _ShiftStartViewState extends ConsumerState<ShiftStartView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // final prefs = await SharedPreferences.getInstance();

      if (await LocationService().isTracking()) {
        ref.read(locationProvider.notifier).setLoading(true);
        ref.read(locationProvider.notifier).updateIsTracking(true);
        await ShiftStartViewModel(ref)
            .syncLocationList(stopTrackingManually: false);
        ref.read(locationProvider.notifier).setLoading(false);
      }
    });

    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   // Listen for changes in tracking state
  //   ref.listenManual(locationProvider, (previous, next) {
  //     if (!next.isTracking) {
  //       context.go('/shift-end');
  //     }
  //   });
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    final viewModel = ShiftStartViewModel(ref);
    final isTracking = ref.watch(locationProvider).isTracking;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Visibility(
            visible: !(ref.watch(locationProvider).isLoading),
            replacement: const CircularProgressIndicator(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isTracking ? 'End Shift' : 'Ready to Start Shift',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Icon(
                  isTracking
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 100,
                  color: isTracking ? Colors.red : Colors.green,
                ),
                const SizedBox(height: 20),
                Text(
                  isTracking ? 'Slide to End Shift' : 'Slide to Start Shift',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                _buildSliderButton(context, viewModel, isTracking),
                const SizedBox(height: 40),
                TextButton(
                  onPressed: () => context.go('/shift-history'),
                  child: const Text(
                    'View shift history',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderButton(
      BuildContext context, ShiftStartViewModel viewModel, bool isTracking) {
    return SlideAction(
      text: isTracking ? 'Slide to End Shift' : 'Slide to Start Shift',
      textStyle: const TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
      outerColor: isTracking ? Colors.red : Colors.green,
      innerColor: Colors.white,
      onSubmit: () async {
        if (isTracking) {
          await viewModel.syncLocationList();
          await viewModel.clearNativeLocationList();
          context.go('/shift-end');
        } else {
          await viewModel.startShift();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                    child: const Row(
                      children: [
                        SizedBox(width: 20),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
                // GestureDetector(
                //   onHorizontalDragUpdate: (details) {
                //     if (details.delta.dx > 0) {
                //       viewModel.startShift();
                //     } else {
                //       viewModel.endShift();
                //     }
                //   },
                //   child: Container(
                //     width: 60,
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(30),
                //     ),
                //     child: Center(
                //       child: Icon(
                //         Icons.arrow_forward_ios,
                //         color: isTracking ? Colors.red : Colors.green,
                //         size: 24,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
