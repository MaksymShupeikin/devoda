import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/map_view.dart';

/// Home screen: the full-screen interactive map.
class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  static const String path = '/map';
  static const String name = 'map';

  static GoRoute get route => GoRoute(
    path: path,
    name: name,
    builder: (context, state) => const MapPage(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(body: MapView());
  }
}
