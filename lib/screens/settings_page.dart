import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/cubits.dart';
import 'package:meal_planning/blocs/settings_bloc.dart';
import 'package:meal_planning/utils/centre.dart';
import 'package:meal_planning/utils/hive_repository.dart';

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
            GestureDetector(
                onTap: () {
                  //TODO: show dialog and then that will send edit category event
                },
                child: Container(
                  margin: EdgeInsets.only(right: Centre.safeBlockHorizontal * 2),
                  width: Centre.safeBlockHorizontal * 6,
                  height: Centre.safeBlockHorizontal * 6,
                  decoration: BoxDecoration(
                      color: Color(color),
                      border: Border.all(color: Colors.white, width: 1.5),
                      borderRadius: const BorderRadius.all(Radius.circular(40))),
                )),
            editingName == null || editingName != name
                ? GestureDetector(
                    onTap: () {
                      context.read<SettingsEditingTextCubit>().editing(type: type.toString().split('.')[1], name: name);
                    },
                    child: Text(name))
                : CategoryTextField(
                    existingCategories: categories.keys.toList(),
                    formKey: formKey,
                    controller: editingController,
                  ),
            Spacer(),
            editingName == null || editingName != name
                ? SizedBox()
                : GestureDetector(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        context
                            .read<SettingsBloc>()
                            .add(SettingsUpdateCategory(type, name, editingController.text, null));
                        editingController.clear();
                        context.read<SettingsEditingTextCubit>().editing(type: "", name: "");
                      }
                    },
                    child: SizedBox(
                      child: Center(
                        child: Icon(Icons.check),
                      ),
                    ),
                  ),
            name == "Other"
                ? SizedBox()
                : GestureDetector(
                    onTap: () {
                      if (editingName == null || editingName != name) {
                        context.read<SettingsBloc>().add(SettingsDeleteCategory(type, name));
                      } else {
                        editingController.clear();
                        context.read<SettingsEditingTextCubit>().editing(type: "", name: "");
                      }
                    },
                    child: SizedBox(
                      child: Center(
                        child: Icon(editingName == null || editingName != name ? Icons.delete : Icons.close),
                      ),
                    ),
                  )
          ],
        )
      ]);
    });
    return [
      Text("Change ${type.toString().split('.')[1]} categories"),
      ...categoryList,
      BlocProvider<SettingsAddColorCubit>(
          create: (_) => SettingsAddColorCubit(),
          child: AddCategoryTextField(type: type, existingCategories: categories.keys.toList())),
      const Divider(color: Colors.grey)
    ];
  }

  @override
  Widget build(BuildContext context) {
    Centre().init(context);

    return SafeArea(
        child: Scaffold(
      backgroundColor: Centre.bgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Centre.safeBlockHorizontal * 2),
        child: BlocBuilder<SettingsEditingTextCubit, List<String>>(builder: (context, editingState) {
          return BlocBuilder<SettingsBloc, SettingsState>(builder: (context, settingsState) {
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
                    editingName:
                        editingState[0] == CategoryType.grocery.toString().split('.')[1] ? editingState[0] : null),
                ...changeArea(
                    context: context,
                    type: CategoryType.recipe,
                    categories: settingsState.recipeCategoriesMap,
                    editingName:
                        editingState[0] == CategoryType.recipe.toString().split('.')[1] ? editingState[0] : null),
                ...changeArea(
                    context: context,
                    type: CategoryType.generic,
                    categories: settingsState.genericCategoriesMap,
                    editingName:
                        editingState[0] == CategoryType.generic.toString().split('.')[1] ? editingState[0] : null)
              ],
            );
          });
        }),
      ),
    ));
  }
}

class CategoryTextField extends StatefulWidget {
  final List<String> existingCategories;
  final TextEditingController controller;
  final GlobalKey formKey;
  const CategoryTextField(
      {super.key, required this.controller, required this.formKey, required this.existingCategories});

  @override
  State<CategoryTextField> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<CategoryTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Centre.safeBlockHorizontal * 60,
      child: Form(
        key: widget.formKey,
        child: TextFormField(
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
            errorStyle: TextStyle(height: 0.5),
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
  const AddCategoryTextField({super.key, required this.existingCategories, required this.type});

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
        Builder(builder: (context) {
          return BlocBuilder<SettingsAddColorCubit, int?>(builder: (context, state) {
            return GestureDetector(
                onTap: () {
                  //TODO: show dialog and then that will send edit category event
                },
                child: Container(
                  margin: EdgeInsets.only(right: Centre.safeBlockHorizontal * 2),
                  width: Centre.safeBlockHorizontal * 6,
                  height: Centre.safeBlockHorizontal * 6,
                  decoration: BoxDecoration(
                      color: Color(state ?? Centre.bgColor.value),
                      border: Border.all(color: Colors.white, width: 1.5),
                      borderRadius: const BorderRadius.all(Radius.circular(40))),
                ));
          });
        }),
        SizedBox(
          width: Centre.safeBlockHorizontal * 60,
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Can\'t be empty';
                } else if (text.length > 100) {
                  return 'Too long';
                } else if (widget.existingCategories.contains(text)) {
                  return 'Category already exists';
                } else if (context.read<SettingsAddColorCubit>().state == null) {
                  return 'No color chosen';
                }
                return null;
              },
              style: Centre.listText,
              decoration: InputDecoration(
                errorStyle: TextStyle(height: 0.5),
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
              context
                  .read<SettingsBloc>()
                  .add(SettingsAddCategory(widget.type, controller.text, context.read<SettingsAddColorCubit>().state!));
              controller.clear();
            }
          },
          child: Container(
            padding: EdgeInsets.all(Centre.safeBlockHorizontal),
            color: Centre.shadowbgColor,
            child: Text(
              "Add",
            ),
          ),
        )
      ],
    );
  }
}
