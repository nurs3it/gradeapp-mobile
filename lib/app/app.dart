import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/providers.dart';

/// Root widget. Theme, router and screens land with the UI kit.
class GradeApp extends ConsumerStatefulWidget {
  const GradeApp({super.key});

  @override
  ConsumerState<GradeApp> createState() => _GradeAppState();
}

class _GradeAppState extends ConsumerState<GradeApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(outboxProvider).flush();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back in the app (e.g. walked from the classroom to the staff room Wi-Fi):
  /// push whatever was marked offline.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.read(outboxProvider).flush();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'GradeApp',
      debugShowCheckedModeBanner: false,
      supportedLocales: [Locale('ru'), Locale('kk'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: Center(child: Text('GradeApp'))),
    );
  }
}
