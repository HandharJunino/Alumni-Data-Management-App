import 'flutter_flow_model.dart';
import 'package:flutter/material.dart';

class EditProfileModel extends FlutterFlowModel {
  ///  State fields for stateful widgets in this page.

  // State field(s) for name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(String?)? nameTextControllerValidator;

  // State field(s) for phone widget.
  FocusNode? phoneFocusNode;
  TextEditingController? phoneTextController;
  String? Function(String?)? phoneTextControllerValidator;

  // State field(s) for email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(String?)? emailTextControllerValidator;

  // State field(s) for socPoc widget.
  FocusNode? socPocFocusNode;
  TextEditingController? socPocTextController;
  String? Function(String?)? socPocTextControllerValidator;

  // State field(s) for country widget.
  FocusNode? countryFocusNode;
  TextEditingController? countryTextController;
  String? Function(String?)? countryTextControllerValidator;

  // State field(s) for priorCourse widget.
  FocusNode? priorCourseFocusNode;
  TextEditingController? priorCourseTextController;
  String? Function(String?)? priorCourseTextControllerValidator;

  // State field(s) for yearOfGraduation widget.
  FocusNode? yearOfGraduationFocusNode;
  TextEditingController? yearOfGraduationTextController;
  String? Function(String?)? yearOfGraduationTextControllerValidator;

  // State field(s) for company widget.
  FocusNode? companyFocusNode;
  TextEditingController? companyTextController;
  String? Function(String?)? companyTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    phoneFocusNode?.dispose();
    phoneTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    socPocFocusNode?.dispose();
    socPocTextController?.dispose();

    countryFocusNode?.dispose();
    countryTextController?.dispose();

    priorCourseFocusNode?.dispose();
    priorCourseTextController?.dispose();

    yearOfGraduationFocusNode?.dispose();
    yearOfGraduationTextController?.dispose();

    companyFocusNode?.dispose();
    companyTextController?.dispose();
  }
}