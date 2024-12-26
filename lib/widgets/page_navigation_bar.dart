import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/import_export_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/screens/settings_page.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/utils/hive_repository.dart';
import 'package:sizer/sizer.dart';

class PageNavigationBar extends StatelessWidget {
  final PageController pageController;
  const PageNavigationBar({super.key, required this.pageController});

  Widget pageNavButton({required int index, required IconData icon}) {
    return GestureDetector(
        onTap: () {
          pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);
        },
        child: Icon(
          icon,
          size: 8.w,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 100.h,
        width: 100.w,
        child: Column(
          children: [
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12.w,
                ),
                Container(
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        color: Centre.shadowbgColor,
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    color: Centre.bgColor,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  width: 60.w,
                  padding: EdgeInsets.all(3.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      pageNavButton(index: 0, icon: Icons.first_page),
                      pageNavButton(index: 1, icon: Icons.pages),
                      pageNavButton(index: 2, icon: Icons.last_page),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(providers: [
                                  BlocProvider.value(
                                      value: context.read<SettingsBloc>()),
                                  BlocProvider(
                                      create: (_) =>
                                          SettingsEditingTextCubit()),
                                  BlocProvider.value(
                                      value: context.read<ImportExportBloc>()),
                                ], child: SettingsPage())))
                        .then((_) {});
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          color: Centre.shadowbgColor,
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Centre.bgColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    width: 10.w,
                    padding: EdgeInsets.all(0.5.w),
                    margin: EdgeInsets.only(left: 4.w),
                    child: Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 7.w,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 3.h,
            )
          ],
        ));
  }
}
