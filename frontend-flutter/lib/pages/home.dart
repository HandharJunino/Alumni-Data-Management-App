import 'package:alumni_app/functions/authentication.dart';
import 'package:flutter/material.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components.dart';
import '../models/alumni_list.dart';
import '../functions/crud.dart';
import 'package:provider/provider.dart';
import 'package:alumni_app/theme_notifier.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  // Controllers
  late final TextEditingController _textController;
  late final FocusNode _textFieldFocusNode;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final socController = TextEditingController();
  final countryController = TextEditingController();
  final priorCourseController = TextEditingController();
  final yearController = TextEditingController();
  final employerController = TextEditingController();
  final interestsController = TextEditingController();
  final eventName = TextEditingController();
  final eventDescription = TextEditingController();
  TimeOfDay fromTime = TimeOfDay.now();
  TimeOfDay toTime = TimeOfDay.now();
  String? _availability;
  String? _expertise;

  // Date/Time
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // Services
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // State variables
  List<dynamic> _alumniList = [];
  List<dynamic> _eventsList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final Map<String, String> _activeFilters = {};
  String? _currentOrdering;

  // Lifecycle methods
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textFieldFocusNode = FocusNode();
    _loadInitialData();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    socController.dispose();
    countryController.dispose();
    priorCourseController.dispose();
    yearController.dispose();
    employerController.dispose();
    interestsController.dispose();
    eventName.dispose();
    eventDescription.dispose();
    super.dispose();
  }

  // Data loading methods
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadAlumni(),
        _loadEvents(),
      ]);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAlumni() async {
    try {
      final alumni = await _apiService.getAlumniList(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        filters: _activeFilters.isNotEmpty ? _activeFilters : null,
        ordering: _currentOrdering,
      );
      setState(() => _alumniList = alumni);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Error loading alumni: $e', isError: true);
    }
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _apiService.getEventsList();
      setState(() => _eventsList = events);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Error loading events: $e', isError: true);
    }
  }

  // UI Building methods
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: CustomTextFormField(
              controller: _textController,
              focusNode: _textFieldFocusNode,
              labelText: 'Search Alumni...',
              onChanged: (_) => EasyDebounce.debounce(
                '_textController',
                const Duration(milliseconds: 500),
                () {
                  setState(() => _searchQuery = _textController.text);
                  _loadAlumni();
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              setState(() => _searchQuery = _textController.text);
              _loadAlumni();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return SizedBox(
      height: 170, // Fixed height for the scrolling container
      child: AsyncListView<dynamic>(
        isLoading: _isLoading,
        items: _eventsList,
        emptyText: 'No events found',
        scrollDirection: Axis.horizontal,
        shrinkWrap: false,
        physics: null,
        itemBuilder: (context, event) => _buildEventCard(event),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12),
      child: AppCard(
        width: 160,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              event['name'] ?? 'No Name',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              event['date'] ?? 'No Date',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlumniList() {
    return AsyncListView<dynamic>(
      isLoading: _isLoading,
      items: _alumniList,
      emptyText: 'No alumni found',
      itemBuilder: (context, alumni) => AlumniListItem(
        alumni: alumni,
        onView: () async {
          final deleted = await Navigator.pushNamed(
            context,
            '/user_profile',
            arguments: {'userId': alumni['id']},
          );
          if (deleted == true) _loadAlumni();
        },
        onEdit: () => Navigator.pushNamed(
          context,
          '/edit_profile',
          arguments: {'userId': alumni['id'].toString()},
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => FormDialog(
        title: 'Add Member',
        submitText: 'Add',
        fields: [
          CustomTextFormField(controller: nameController, labelText: 'Name'),
          CustomTextFormField(
              controller: phoneController, labelText: 'Phone'),
          CustomTextFormField(
            controller: emailController,
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          CustomTextFormField(
            controller: socController,
            labelText: 'SOC Point Of Contact',
          ),
          AppDropdownFormField<String>(
            value: _availability,
            labelText: 'Availability',
            items: availabilityOptions,
            itemLabel: (item) => item,
            onChanged: (value) => setState(() => _availability = value),
          ),
          TimePickerFormField(
            selectedTime: fromTime,
            labelText: 'Time to Contact From',
            onTimeSelected: (time) => setState(() => fromTime = time),
          ),
          TimePickerFormField(
            selectedTime: toTime,
            labelText: 'Time to Contact To',
            onTimeSelected: (time) => setState(() => toTime = time),
          ),
          CustomTextFormField(
              controller: countryController, labelText: 'Country'),
          CustomTextFormField(
            controller: priorCourseController,
            labelText: 'Prior Course',
          ),
          CustomTextFormField(
            controller: yearController,
            labelText: 'Year Of Graduation',
            keyboardType: TextInputType.number,
          ),
          CustomTextFormField(
            controller: employerController,
            labelText: 'Current Employer',
          ),
          CustomTextFormField(
            controller: interestsController,
            labelText: 'Areas of Interest',
          ),
          AppDropdownFormField<String>(
            value: _expertise,
            labelText: 'Area of Expertise',
            items: expertiseOptions,
            itemLabel: (item) => item,
            onChanged: (value) => setState(() => _expertise = value),
          ),
        ],
        onSubmit: () async {
          final alumniData = {
            'name': nameController.text,
            'phone': phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            'email': emailController.text,
            'soc_poc': socController.text,
            'availability': _availability ?? '',
            'time_to_contact_from':
                '${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}:00',
            'time_to_contact_to':
                '${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}:00',
            'country': countryController.text,
            'prior_course': priorCourseController.text,
            'year_of_graduation': int.parse(yearController.text),
            'company': employerController.text,
            'area_of_expertise': [_expertise ?? ''],
          };
          try {
            await _apiService.createAlumni(alumniData);
            await _loadAlumni();
            if (!dialogContext.mounted) return;
            Navigator.pop(dialogContext);
            if (!mounted) return;
            AppSnackBar.show(context, 'Alumni added successfully!',
                isSuccess: true);
          } catch (e) {
            if (!dialogContext.mounted) return;
            AppSnackBar.show(dialogContext, 'Failed to add alumni: $e',
                isError: true);
          }
        },
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => FormDialog(
        title: 'Add Event',
        submitText: 'Add',
        fields: [
          CustomTextFormField(
              controller: eventName, labelText: 'Event Name'),
          DatePickerFormField(
            selectedDate: selectedDate,
            labelText: 'Event Date',
            onDateSelected: (date) => setState(() => selectedDate = date),
          ),
          TimePickerFormField(
            selectedTime: selectedTime,
            labelText: 'Time',
            onTimeSelected: (time) => setState(() => selectedTime = time),
          ),
          CustomTextFormField(
            controller: eventDescription,
            labelText: 'Description',
          ),
        ],
        onSubmit: () async {
          final eventData = {
            'name': eventName.text,
            'date':
                "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
            'time':
                "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00",
            'description': eventDescription.text,
          };
          try {
            await _apiService.createEvent(eventData);
            await _loadEvents();
            if (!dialogContext.mounted) return;
            Navigator.pop(dialogContext);
            if (!mounted) return;
            AppSnackBar.show(context, 'Event added successfully!',
                isSuccess: true);
          } catch (e) {
            if (!dialogContext.mounted) return;
            AppSnackBar.show(dialogContext, 'Failed to add event: $e',
                isError: true);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: OverflowMenuButton(
            icon: FaIcon(
              FontAwesomeIcons.adn,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
            items: [
              OverflowMenuItem(
                icon: Icons.brightness_6,
                label: 'Toggle Theme',
                onTap: () => Provider.of<ThemeNotifier>(context, listen: false)
                    .toggleTheme(),
              ),
              OverflowMenuItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () {
                  _authService.logout();
                  Navigator.pushNamed(context, '/auth');
                },
              ),
            ],
          ),
          title: Text(
            'Alumni Network',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            OverflowMenuButton(
              icon: Icon(
                Icons.add_circle,
                color: Theme.of(context).appBarTheme.iconTheme?.color,
                size: 24,
              ),
              positionBuilder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                return RelativeRect.fromLTRB(
                  screenWidth - 200,
                  kToolbarHeight,
                  screenWidth,
                  kToolbarHeight + 200,
                );
              },
              items: [
                OverflowMenuItem(
                  icon: Icons.person_add,
                  label: 'Add Member',
                  onTap: _showAddMemberDialog,
                ),
                OverflowMenuItem(
                  icon: Icons.event,
                  label: 'Add Event',
                  onTap: _showAddEventDialog,
                ),
              ],
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadInitialData,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildEventsList(),
                _buildAlumniList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
