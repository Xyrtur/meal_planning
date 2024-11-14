import 'dart:ui';

import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/utils/hive_repository.dart';
import 'package:sizer/sizer.dart';

// ignore: must_be_immutable
class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final formKey = GlobalKey<FormState>();
  TextEditingController editingController = TextEditingController(text: "");

  List<Widget> changeArea(
      {required BuildContext context,
      required CategoryType type,
      required Map<String, int> categories,
      String? editingName}) {
    List<Widget> categoryList = [];
    categories.forEach((name, color) {
      categoryList.addAll([
        Row(
          children: [
            BlocProvider<SettingsAddColorCubit>(
                create: (context) => SettingsAddColorCubit(color),
                child: ChooseColorBtn(
                  type: type,
                  name: name,
                )),
            editingName == null || editingName != name
                ? GestureDetector(
                    onTap: () {
                      context.read<SettingsEditingTextCubit>().editing(
                          type: type.toString().split('.')[1], name: name);
                    },
                    child: Text(name))
                : CategoryTextField(
                    existingCategories: categories.keys.toList(),
                    formKey: formKey,
                    controller: editingController,
                  ),
            const Spacer(),
            editingName == null || editingName != name
                ? const SizedBox()
                : GestureDetector(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        context.read<SettingsBloc>().add(SettingsUpdateCategory(
                            type, name, editingController.text, null));
                        editingController.clear();
                        context
                            .read<SettingsEditingTextCubit>()
                            .editing(type: "", name: "");
                      }
                    },
                    child: const SizedBox(
                      child: Center(
                        child: Icon(Icons.check),
                      ),
                    ),
                  ),
            name == "Other"
                ? const SizedBox()
                : GestureDetector(
                    onTap: () {
                      if (editingName == null || editingName != name) {
                        context
                            .read<SettingsBloc>()
                            .add(SettingsDeleteCategory(type, name));
                      } else {
                        editingController.clear();
                        context
                            .read<SettingsEditingTextCubit>()
                            .editing(type: "", name: "");
                      }
                    },
                    child: SizedBox(
                      child: Center(
                        child: Icon(editingName == null || editingName != name
                            ? Icons.delete
                            : Icons.close),
                      ),
                    ),
                  )
          ],
        )
      ]);
    });
    return [
      Text(
        "Change ${type.toString().split('.')[1]} categories",
        style: Centre.listText,
      ),
      ...categoryList,
      BlocProvider<SettingsAddColorCubit>(
          create: (_) => SettingsAddColorCubit(null),
          child: AddCategoryTextField(
              type: type, existingCategories: categories.keys.toList())),
      const Divider(
        color: Colors.grey,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Centre.bgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: BlocBuilder<SettingsEditingTextCubit, List<String>>(
            builder: (context, editingState) {
          return BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, settingsState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Settings",
                  style: Centre.titleText,
                ),
                ...changeArea(
                    context: context,
                    type: CategoryType.grocery,
                    categories: settingsState.groceryCategoriesMap,
                    editingName: editingState[0] ==
                            CategoryType.grocery.toString().split('.')[1]
                        ? editingState[0]
                        : null),
                ...changeArea(
                    context: context,
                    type: CategoryType.recipe,
                    categories: settingsState.recipeCategoriesMap,
                    editingName: editingState[0] ==
                            CategoryType.recipe.toString().split('.')[1]
                        ? editingState[0]
                        : null),
                ...changeArea(
                    context: context,
                    type: CategoryType.generic,
                    categories: settingsState.genericCategoriesMap,
                    editingName: editingState[0] ==
                            CategoryType.generic.toString().split('.')[1]
                        ? editingState[0]
                        : null),
                GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      margin:
                          EdgeInsets.symmetric(horizontal: 15.w, vertical: 2.h),
                      height: 6.h,
                      child: Center(
                        child: Text(
                          "Finish and apply changes",
                          style: Centre.semiTitleText,
                        ),
                      ),
                    ))
              ],
            );
          });
        }),
      ),
    ));
  }
}

class ChooseColorBtn extends StatelessWidget {
  final CategoryType type;
  final String name;
  const ChooseColorBtn({super.key, required this.type, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          showAlignedDialog(
              followerAnchor: Alignment.topLeft,
              targetAnchor: Alignment.bottomLeft,
              avoidOverflow: true,
              barrierColor: Colors.transparent,
              context: context,
              builder: (BuildContext dialogContext) => GestureDetector(
                  onTap: () {
                    context.read<SettingsBloc>().add(SettingsUpdateCategory(
                        type,
                        name,
                        null,
                        context.read<SettingsAddColorCubit>().state));
                    Navigator.pop(dialogContext);
                  },
                  child: const Scaffold(
                      backgroundColor: Colors.transparent,
                      body: ChooseColorDialog())));
        },
        child: BlocBuilder<SettingsAddColorCubit, int?>(
            builder: (context, chosenColor) => Container(
                  margin: EdgeInsets.only(right: 2.w),
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                      color: Color(chosenColor!),
                      border: Border.all(color: Colors.white, width: 1.5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(40))),
                )));
  }
}

class CategoryTextField extends StatefulWidget {
  final List<String> existingCategories;
  final TextEditingController controller;
  final GlobalKey formKey;
  const CategoryTextField(
      {super.key,
      required this.controller,
      required this.formKey,
      required this.existingCategories});

  @override
  State<CategoryTextField> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<CategoryTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      child: Form(
        key: widget.formKey,
        child: TextFormField(
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.disabled,
          validator: (text) {
            if (text == null || text.isEmpty) {
              return 'Can\'t be empty';
            } else if (text.length > 100) {
              return 'Too long';
            } else if (widget.existingCategories.contains(text)) {
              return 'Category already exists';
            }
            return null;
          },
          style: Centre.listText,
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0.5),
            hintText: "Category name",
            hintStyle: Centre.listText.copyWith(color: Colors.blueGrey),
            isDense: true,
          ),
        ),
      ),
    );
  }
}

class AddCategoryTextField extends StatefulWidget {
  final CategoryType type;
  final List<String> existingCategories;
  const AddCategoryTextField(
      {super.key, required this.existingCategories, required this.type});

  @override
  State<AddCategoryTextField> createState() => _AddCategoryTextFieldState();
}

class _AddCategoryTextFieldState extends State<AddCategoryTextField> {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<SettingsAddColorCubit, int?>(
            builder: (unUsedContext, state) {
          return Builder(builder: (context) {
            return GestureDetector(
                onTap: () {
                  showAlignedDialog(
                      followerAnchor: Alignment.topLeft,
                      targetAnchor: Alignment.bottomLeft,
                      barrierColor: Colors.transparent,
                      offset: Offset(6.w, 6.w),
                      context: context,
                      builder: (BuildContext dialogContext) => GestureDetector(
                            onTap: () => Navigator.pop(dialogContext),
                            child: Scaffold(
                              backgroundColor: Colors.transparent,
                              body: BlocProvider<SettingsAddColorCubit>.value(
                                value: context.read<SettingsAddColorCubit>(),
                                child: const ChooseColorDialog(),
                              ),
                            ),
                          ));
                },
                child: Container(
                  margin: EdgeInsets.only(right: 2.w),
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                      color: Color(state ?? Centre.bgColor.value),
                      border: Border.all(color: Colors.white, width: 1.5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(40))),
                ));
          });
        }),
        SizedBox(
          width: 60.w,
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autovalidateMode: AutovalidateMode.disabled,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Can\'t be empty';
                } else if (text.length > 100) {
                  return 'Too long';
                } else if (widget.existingCategories.contains(text)) {
                  return 'Category already exists';
                } else if (context.read<SettingsAddColorCubit>().state ==
                    null) {
                  return 'No color chosen';
                }
                return null;
              },
              style: Centre.listText,
              decoration: InputDecoration(
                errorStyle: const TextStyle(height: 0.5),
                hintText: "Category name",
                hintStyle: Centre.listText.copyWith(color: Colors.blueGrey),
                isDense: true,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (formKey.currentState!.validate()) {
              context.read<SettingsBloc>().add(SettingsAddCategory(
                  widget.type,
                  controller.text,
                  context.read<SettingsAddColorCubit>().state!));
              controller.clear();
              context.read<SettingsAddColorCubit>().selectColor(color: null);
            }
          },
          child: Container(
            padding: EdgeInsets.all(1.w),
            color: Centre.shadowbgColor,
            child: const Text(
              "Add",
            ),
          ),
        )
      ],
    );
  }
}

class ChooseColorDialog extends StatelessWidget {
  const ChooseColorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    Widget colourBtn(int i) {
      return GestureDetector(
        onTap: () {
          context
              .read<SettingsAddColorCubit>()
              .selectColor(color: Centre.colors[i].value);
        },
        child: BlocBuilder<SettingsAddColorCubit, int?>(
            builder: (context, chosenColor) {
          return Container(
            margin: EdgeInsets.only(top: 1.3.h),
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
                color: Centre.colors[i],
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(40))),
            child: chosenColor == Centre.colors[i].value
                ? Icon(
                    Icons.check,
                    size: 5.w,
                    color: Centre.bgColor,
                  )
                : null,
          );
        }),
      );
    }

    return AlertDialog(
        contentPadding: EdgeInsets.all(2.w),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        backgroundColor: Centre.shadowbgColor,
        elevation: 0,
        content: SizedBox(
            height: 18.h,
            width: 50.w,
            child: Column(
              children: [
                for (int i = 0; i < 4; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (int j = 0; j < 5; j++) colourBtn(i * 5 + j)
                    ],
                  )
              ],
            )));
  }
}
