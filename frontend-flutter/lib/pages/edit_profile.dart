import 'package:flutter/material.dart';
import 'package:alumni_app/models/edit_profile_model.dart';
export 'package:alumni_app/models/edit_profile_model.dart';
import 'package:alumni_app/functions/crud.dart';
import 'package:alumni_app/components.dart';

class EditProfileWidget extends StatefulWidget {
  final String userId;
  const EditProfileWidget({super.key, required this.userId});

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  late EditProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;

  String? _availability;
  List<String> _expertise = [];
  TimeOfDay _timeFrom = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _timeTo = const TimeOfDay(hour: 23, minute: 59);

  @override
  void initState() {
    super.initState();
    _model = EditProfileModel();

    _model.nameTextController = TextEditingController();
    _model.nameFocusNode = FocusNode();
    _model.phoneTextController = TextEditingController();
    _model.phoneFocusNode = FocusNode();
    _model.emailTextController = TextEditingController();
    _model.emailFocusNode = FocusNode();
    _model.socPocTextController = TextEditingController();
    _model.socPocFocusNode = FocusNode();
    _model.countryTextController = TextEditingController();
    _model.countryFocusNode = FocusNode();
    _model.priorCourseTextController = TextEditingController();
    _model.priorCourseFocusNode = FocusNode();
    _model.yearOfGraduationTextController = TextEditingController();
    _model.yearOfGraduationFocusNode = FocusNode();
    _model.companyTextController = TextEditingController();
    _model.companyFocusNode = FocusNode();

    _loadUserData();
  }

  TimeOfDay _parseTime(dynamic value, TimeOfDay fallback) {
    if (value is! String) return fallback;
    final parts = value.split(':');
    if (parts.length < 2) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return fallback;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _apiService.getUserDetails(widget.userId);
      if (!mounted) return;
      setState(() {
        _model.nameTextController!.text = userData['name'] ?? '';
        _model.phoneTextController!.text = userData['phone'] ?? '';
        _model.emailTextController!.text = userData['email'] ?? '';
        _model.socPocTextController!.text = userData['soc_poc'] ?? '';
        _model.countryTextController!.text = userData['country'] ?? '';
        _model.priorCourseTextController!.text =
            userData['prior_course'] ?? '';
        _model.yearOfGraduationTextController!.text =
            userData['year_of_graduation']?.toString() ?? '';
        _model.companyTextController!.text = userData['company'] ?? '';
        _availability = userData['availability'] as String?;
        _expertise = List<String>.from(userData['area_of_expertise'] ?? []);
        _timeFrom = _parseTime(userData['time_to_contact_from'], _timeFrom);
        _timeTo = _parseTime(userData['time_to_contact_to'], _timeTo);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Error loading user data: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    final alumniData = {
      'name': _model.nameTextController!.text,
      'phone': _model.phoneTextController!.text.replaceAll(RegExp(r'[^0-9]'), ''),
      'email': _model.emailTextController!.text,
      'soc_poc': _model.socPocTextController!.text,
      'availability': _availability ?? '',
      'time_to_contact_from':
          '${_timeFrom.hour.toString().padLeft(2, '0')}:${_timeFrom.minute.toString().padLeft(2, '0')}:00',
      'time_to_contact_to':
          '${_timeTo.hour.toString().padLeft(2, '0')}:${_timeTo.minute.toString().padLeft(2, '0')}:00',
      'country': _model.countryTextController!.text,
      'prior_course': _model.priorCourseTextController!.text,
      'year_of_graduation':
          int.tryParse(_model.yearOfGraduationTextController!.text) ?? 0,
      'company': _model.companyTextController!.text,
      'area_of_expertise': _expertise,
    };

    try {
      await _apiService.updateAlumni(int.parse(widget.userId), alumniData);
      if (!mounted) return;
      AppSnackBar.show(context, 'Profile updated successfully!',
          isSuccess: true);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Failed to update profile: $e',
          isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).textTheme.headlineMedium?.color,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'Outfit',
                fontSize: 22,
                letterSpacing: 0.0,
              ),
        ),
      ),
      body: SafeArea(
        top: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Container(
                                width: 90,
                                height: 90,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildField(
                      context,
                      CustomTextFormField(
                        controller: _model.nameTextController,
                        focusNode: _model.nameFocusNode,
                        textCapitalization: TextCapitalization.words,
                        labelText: 'Name',
                        labelStyle: _fieldLabelStyle(context),
                        fillColor: Theme.of(context).colorScheme.surface,
                        borderColor: Theme.of(context).colorScheme.tertiary,
                        contentPadding: _fieldContentPadding,
                        validator: _model.nameTextControllerValidator,
                      ),
                    ),
                    _buildField(
                      context,
                      CustomTextFormField(
                        controller: _model.phoneTextController,
                        focusNode: _model.phoneFocusNode,
                        labelText: 'Phone',
                        labelStyle: _fieldLabelStyle(context),
                        fillColor: Theme.of(context).colorScheme.surface,
                        borderColor: Theme.of(context).colorScheme.tertiary,
                        contentPadding: _fieldContentPadding,
                        keyboardType: TextInputType.phone,
                        validator: _model.phoneTextControllerValidator,
                      ),
                    ),
                    _buildField(
                      context,
                      CustomTextFormField(
                        controller: _model.emailTextController,
                        focusNode: _model.emailFocusNode,
                        labelText: 'Email',
                        labelStyle: _fieldLabelStyle(context),
                        fillColor: Theme.of(context).colorScheme.surface,
                        borderColor: Theme.of(context).colorScheme.tertiary,
                        contentPadding: _fieldContentPadding,
                        keyboardType: TextInputType.emailAddress,
                        validator: _model.emailTextControllerValidator,
                      ),
                    ),
                    _buildField(
                      context,
                      CustomTextFormField(
                        controller: _model.socPocTextController,
                        focusNode: _model.socPocFocusNode,
                        labelText: 'SOC Point Of Contact',
                        labelStyle: _fieldLabelStyle(context),
                        fillColor: Theme.of(context).colorScheme.surface,
                        borderColor: Theme.of(context).colorScheme.tertiary,
                        contentPadding: _fieldContentPadding,
                        validator: _model.socPocTextControllerValidator,
                      ),
                    ),
                    _buildField(
                      context,
                      AppDropdownFormField<String>(
                        value: _availability,
                        labelText: 'Availability',
                        items: availabilityOptions,
                        itemLabel: (item) => item,
                        fillColor: Theme.of(context).colorScheme.surface,
                        borderColor: Theme.of(context).colorScheme.tertiary,
                        onChanged: (value) =>
                            setState(() => _availability = value),
                      ),
                    ),
                    _buildField(
                      context,
                      TimePickerFormField(
                        selectedTime: _timeFrom,
                        labelText: 'Time to Contact From',
                        onTimeSelected: (time) =>
                            setState(() => _timeFrom = time),
                      ),
                    ),
                    _buildField(
                      context,
                      TimePickerFormField(
                        selectedTime: _timeTo,
                        labelText: 'Time to Contact To',
                        onTimeSelected: (time) =>
                            setState(() => _timeTo = time),
                      ),
                    ),
                    _buildField(
                      context,
                      CustomTextFormField(
                        controller: _model.countryTextController,
                        focusNode: _model.countryFocusNode,
                        textCapitalization: TextCapitalization.words,
                        labelText: 'Country',
                        labelStyle: _fieldLabelStyle(context),
                        fillColor: Theme.of(context).colorScheme.surface,
                        borderColor: Theme.of(context).colorScheme.tertiary,
                        contentPadding: _fieldContentPadding,
                        validator: _model.countryTextControllerValidator,
                      ),
                    ),
                    _buildField(
                      context,
                      CustomTextFormField(
                        controller: _model.priorCourseTextController,
                        focusNode: _model.priorCourseFocusNode,
                        textCapitalization: TextCapitalization.words,
                        labelText: 'Prior Course',
                        labelStyle: _fieldLabelStyle(context),
                        fillColor: Theme.of(context).colorScheme.surface,
                        borderColor: Theme.of(context).colorScheme.tertiary,
                        contentPadding: _fieldContentPadding,
                        validator: _model.priorCourseTextControllerValidator,
                      ),
                    ),
                    _buildField(
                      context,
                      CustomTextFormField(
                        controller: _model.yearOfGraduationTextController,
                        focusNode: _model.yearOfGraduationFocusNode,
                        labelText: 'Year Of Graduation',
                        labelStyle: _fieldLabelStyle(context),
                        fillColor: Theme.of(context).colorScheme.surface,
                        borderColor: Theme.of(context).colorScheme.tertiary,
                        contentPadding: _fieldContentPadding,
                        keyboardType: TextInputType.number,
                        validator:
                            _model.yearOfGraduationTextControllerValidator,
                      ),
                    ),
                    _buildField(
                      context,
                      CustomTextFormField(
                        controller: _model.companyTextController,
                        focusNode: _model.companyFocusNode,
                        textCapitalization: TextCapitalization.words,
                        labelText: 'Current Employer',
                        labelStyle: _fieldLabelStyle(context),
                        fillColor: Theme.of(context).colorScheme.surface,
                        borderColor: Theme.of(context).colorScheme.tertiary,
                        contentPadding: _fieldContentPadding,
                        validator: _model.companyTextControllerValidator,
                      ),
                    ),
                    _buildField(
                      context,
                      AppMultiSelectChips(
                        labelText: 'Area of Expertise',
                        options: expertiseOptions,
                        selected: _expertise,
                        onChanged: (values) =>
                            setState(() => _expertise = values),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0, 0.05),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 24),
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isSaving ? 'Saving...' : 'Save Changes',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  static const _fieldContentPadding =
      EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24);

  TextStyle? _fieldLabelStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'Outfit',
            letterSpacing: 0.0,
          );

  Widget _buildField(BuildContext context, Widget field) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
      child: field,
    );
  }
}
