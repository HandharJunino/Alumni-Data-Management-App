import 'package:flutter/material.dart';

class AuthPageModel {
  /// State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  late TabController tabBarController;

  AuthPageModel({required TickerProvider vsync}) {
    tabBarController = TabController(length: 2, vsync: vsync);
  }

  // State field(s) for userName widget.
  FocusNode? userNameFocusNode;
  late TextEditingController userNameTextController;
  String? Function(String?)? userNameTextControllerValidator;

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  late TextEditingController emailAddressTextController;
  String? Function(String?)? emailAddressTextControllerValidator;

  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  late TextEditingController passwordTextController;
  late bool passwordVisibility;
  String? Function(String?)? passwordTextControllerValidator;

  // State field(s) for emailAddress_Create widget.
  FocusNode? emailAddressCreateFocusNode;
  late TextEditingController emailAddressCreateTextController;
  String? Function(String?)? emailAddressCreateTextControllerValidator;

  // State field(s) for password_Create widget.
  FocusNode? passwordCreateFocusNode;
  late TextEditingController passwordCreateTextController;
  late bool passwordCreateVisibility;
  String? Function(String?)? passwordCreateTextControllerValidator;

  // State field(s) for passwordConfirm widget.
  FocusNode? passwordConfirmFocusNode;
  late TextEditingController passwordConfirmTextController;
  late bool passwordConfirmVisibility;
  String? Function(String?)? passwordConfirmTextControllerValidator;

  void initState(BuildContext context) {
    passwordVisibility = false;
    passwordCreateVisibility = false;
    passwordConfirmVisibility = false;

    emailAddressTextController = TextEditingController();
    passwordTextController = TextEditingController();
    userNameTextController = TextEditingController();
    emailAddressCreateTextController = TextEditingController();
    passwordCreateTextController = TextEditingController();
    passwordConfirmTextController = TextEditingController();
  }

  void dispose() {
    tabBarController.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressTextController.dispose();

    passwordFocusNode?.dispose();
    passwordTextController.dispose();

    userNameFocusNode?.dispose();
    userNameTextController.dispose();

    emailAddressCreateFocusNode?.dispose();
    emailAddressCreateTextController.dispose();

    passwordCreateFocusNode?.dispose();
    passwordCreateTextController.dispose();

    passwordConfirmFocusNode?.dispose();
    passwordConfirmTextController.dispose();
  }
}
