import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/screens/landing_pageview.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/utils/hive_repository.dart';
import 'package:page_transition/page_transition.dart';
// Sentry code to get emailed exceptions
import 'package:sentry_flutter/sentry_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    Centre().init(context);
    return Material(
        color: Colors.transparent,
        child: AnimatedSplashScreen.withScreenFunction(
            backgroundColor: Centre.bgColor,
            pageTransitionType: PageTransitionType.fade,
            duration: 500,
            splash: LottieBuilder.asset(
              "assets/splash_animation.json",
              width: Centre.safeBlockHorizontal * 20,
            ),
            screenFunction: () async {
              // Sentry code to get emailed exceptions
              try {
                context.read<HiveRepository>().cacheInitialData();
                return RepositoryProvider.value(
                  value: context.read<HiveRepository>(),
                  child: MultiBlocProvider(providers: [
                    BlocProvider<SettingsBloc>(
                      create: (_) => SettingsBloc(context.read<HiveRepository>()),
                    ),
                  ], child: LandingPageView()),
                );

                // Sentry code to get emailed exceptions
              } catch (exception, stackTrace) {
                print("Here it issss: $exception\n $stackTrace");
                await Sentry.captureException(
                  exception,
                  stackTrace: stackTrace,
                );
                return const SizedBox();
              }
            }));
  }
}
