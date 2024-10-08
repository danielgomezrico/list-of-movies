import 'package:flutter/material.dart';
import 'package:movie_flutter/api/api.dart';
import 'package:movie_flutter/common/database/database.dart';
import 'package:movie_flutter/common/di/modules.dart';
import 'package:movie_flutter/common/log.dart';
import 'package:movie_flutter/common/result.dart';
import 'package:movie_flutter/common/theme/custom_theme.dart';

Future<void> main() async {
  await setupServices();

  runApp(const MyApp());
}

Future<void> setupServices() async {
  await CommonModule.config().setup().onError((e, s) {
    log.e('[main] Error initializing .env', error: e, stackTrace: s);
    return Result.error(e);
  });

  Api.setup(CommonModule.config().apiBaseUrl());

  await Database.initialize(CommonModule.storages()).onError((e, s) {
    log.e('[main] Error initializing database', error: e, stackTrace: s);
    return Result.error(e);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = CommonModule.router();

    return MaterialApp(
      title: 'Movies App',
      theme: CustomTheme.light,
      darkTheme: CustomTheme.dark,
      navigatorKey: router.navigatorKey,
      initialRoute: router.initialRoute,
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
