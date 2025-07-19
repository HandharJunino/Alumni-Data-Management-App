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

  // State field(s) for yourName widget.
  FocusNode? yourNameFocusNode;
  TextEditingController? yourNameTextController;
  String? Function(String?)? yourNameTextControllerValidator;

  // State field(s) for city widget.
  FocusNode? cityFocusNode;
  TextEditingController? cityTextController;
  String? Function(String?)? cityTextControllerValidator;

  // State field(s) for state widget.
  String? stateValue;
  FormFieldController<String>? stateValueController;

  // State field(s) for myBio widget.
  FocusNode? myBioFocusNode;
  TextEditingController? myBioTextController;
  String? Function(String?)? myBioTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    yourNameFocusNode?.dispose();
    yourNameTextController?.dispose();

    cityFocusNode?.dispose();
    cityTextController?.dispose();

    myBioFocusNode?.dispose();
    myBioTextController?.dispose();
  }
}