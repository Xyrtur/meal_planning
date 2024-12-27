import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/import_export_bloc.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/screens/settings_page.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:sizer/sizer.dart';

class PageNavigationBar extends StatelessWidget {
  final PageController pageController;
  const PageNavigationBar({super.key, required this.pageController});

  Widget pageNavButton(
      {required PageSelected page,
      required IconData icon,
      required bool isSelected,
      required BuildContext context}) {
    return GestureDetector(
        onTap: () {
          pageController.animateToPage(page.index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut);

          context.read<NavbarCubit>().changePage(page: page);
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  width: 3,
                  color: isSelected ? Centre.primaryColor : Colors.transparent),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Icon(
              icon,
              size: 6.w,
            ),
          ),
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
                  width: 55.w,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                  child: BlocBuilder<NavbarCubit, PageSelected>(
                      builder: (_, pageSelected) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        pageNavButton(
                            context: context,
                            page: PageSelected.weeklyPlanning,
                            isSelected:
                                pageSelected == PageSelected.weeklyPlanning,
                            icon: FontAwesomeIcons.plateWheat),
                        pageNavButton(
                            context: context,
                            page: PageSelected.grocery,
                            isSelected: pageSelected == PageSelected.grocery,
                            icon: FontAwesomeIcons.cartShopping),
                        pageNavButton(
                            context: context,
                            page: PageSelected.recipes,
                            isSelected: pageSelected == PageSelected.recipes,
                            icon: FontAwesomeIcons.filePen),
                      ],
                    );
                  }),
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
