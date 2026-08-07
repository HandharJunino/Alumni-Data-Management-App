import 'flutter_flow_model.dart';
import 'package:alumni_app/pages/edit_profile.dart' show EditProfileWidget;
import 'package:flutter/material.dart';

class FormFieldController<T> extends ValueNotifier<T?> {
  FormFieldController(this.initialValue) : super(initialValue);

  final T? initialValue;

  void reset() => value = initialValue;

  void update() => notifyListeners();
}

// If the initial value is a list (which it is for multiselect),
// we need to use this controller to avoid a pass by reference issue
// that can result in the initial value being modified.
class FormListFieldController<T> extends FormFieldController<List<T>> {
  FormListFieldController(super.initialValue)
      : _initialListValue = List<T>.from(initialValue ?? []);

  final List<T>? _initialListValue;

  @override
  void reset() => value = List<T>.from(_initialListValue ?? []);
}

class EditProfileModel extends FlutterFlowModel<EditProfileWidget> {
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