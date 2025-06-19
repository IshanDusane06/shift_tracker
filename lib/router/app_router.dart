import 'package:go_router/go_router.dart';
import 'package:location_tracker/screens/shift_end_screen.dart';
import 'package:location_tracker/screens/shift_start_screen.dart';
import 'package:location_tracker/views/shift_end_view.dart';
import 'package:location_tracker/views/shift_history.dart';
import 'package:location_tracker/views/shift_start_view.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const ShiftStartView(),
        routes: [
          GoRoute(
            path: 'shift-history',
            builder: (context, state) => const ShiftHistoryView(),
          ),
        ]),
    GoRoute(
      path: '/shift-end',
      builder: (context, state) => const ShiftEndView(),
    ),
  ],
);
