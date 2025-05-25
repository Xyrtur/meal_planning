import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/screens/splash_screen.dart';
import 'package:meal_planning/utils/hive_repository.dart';
import 'package:sizer/sizer.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(GroceryItemAdapter());
  Hive.registerAdapter(RecipeAdapter());

  await Hive.openBox<Recipe>('remcipesBox');
  await Hive.openBox<dynamic>('mealPlanmingBox');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // Sentry code to get emailed exceptions
  await SentryFlutter.init((options) {
    options.dsn = 'https://8457a9015b0f4e978bd2078b054503cb@o4505104841965568.ingest.sentry.io/4505104845766656';
  },
      appRunner: () => runApp(const MealPlanningApp()
          // Sentry code to get emailed exceptions
          ));
  runApp(const MealPlanningApp());
}

class MealPlanningApp extends StatelessWidget {
  const MealPlanningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) => MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'GB'),
        ],
        title: "Just Eat",
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.amber,
          fontFamily: 'Raleway',
        ),
        home: RepositoryProvider(create: (context) => HiveRepository(), child: const SplashScreen()),
      ),
    );
  }
}
