import 'package:flutter/material.dart';
import 'package:alumni_app/models/profile_model.dart';
import 'package:alumni_app/functions/crud.dart';
import 'package:alumni_app/components.dart';

class UserProfileWidget extends StatefulWidget {
  final userId;
  const UserProfileWidget({super.key, required this.userId});

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget>
    with TickerProviderStateMixin {
  late UserProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final ApiService _apiService = ApiService();
  Map<String, dynamic> userData = {};

  List<dynamic> _attendedEvents = [];
  bool _eventsLoading = true;
  List<dynamic> _previousContacts = [];
  bool _contactsLoading = true;

  @override
  void initState() {
    super.initState();
    _model = UserProfileModel();

    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    )..addListener(() => setState(() {}));
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _apiService.getUserDetails(widget.userId.toString());
      if (!mounted) return;
      setState(() => userData = data);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Error loading user data: $e', isError: true);
    }
  }

  Future<void> _loadAttendedEvents() async {
    try {
      final events =
          await _apiService.getAlumniEvents(int.parse(widget.userId.toString()));
      if (!mounted) return;
      setState(() {
        _attendedEvents = events;
        _eventsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Error loading attended events: $e',
          isError: true);
      setState(() => _eventsLoading = false);
    }
  }

  Future<void> _loadPreviousContacts() async {
    try {
      final contacts = await _apiService.getPreviousContacts(
        alumniId: int.parse(widget.userId.toString()),
      );
      if (!mounted) return;
      setState(() {
        _previousContacts = contacts;
        _contactsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Error loading previous contacts: $e',
          isError: true);
      setState(() => _contactsLoading = false);
    }
  }

  void _showMarkAttendedDialog() async {
    List<Map<String, dynamic>> events;
    try {
      events = await _apiService.getEventsList();
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Error loading events: $e', isError: true);
      return;
    }
    if (!mounted) return;

    Map<String, dynamic>? selectedEvent;
    DateTime attendedOn = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => FormDialog(
          title: 'Mark Attended',
          submitText: 'Save',
          fields: [
            AppDropdownFormField<Map<String, dynamic>>(
              value: selectedEvent,
              labelText: 'Event',
              items: events,
              itemLabel: (event) => '${event['name']} (${event['date']})',
              onChanged: (value) =>
                  setDialogState(() => selectedEvent = value),
            ),
            DatePickerFormField(
              selectedDate: attendedOn,
              labelText: 'Attended On',
              firstDate: DateTime(2000),
              onDateSelected: (date) =>
                  setDialogState(() => attendedOn = date),
            ),
          ],
          onSubmit: () async {
            if (selectedEvent == null) {
              AppSnackBar.show(dialogContext, 'Please select an event',
                  isError: true);
              return;
            }
            try {
              await _apiService.createAlumniEvent({
                'alumni': int.parse(widget.userId.toString()),
                'event': selectedEvent!['id'],
                'attendance_status': true,
                'attended_on': attendedOn.toIso8601String(),
              });
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              await _loadAttendedEvents();
            } catch (e) {
              if (!dialogContext.mounted) return;
              AppSnackBar.show(
                  dialogContext, 'Failed to record attendance: $e',
                  isError: true);
            }
          },
        ),
      ),
    );
  }

  void _showLogContactDialog() {
    final modeController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime contactDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => FormDialog(
          title: 'Log Contact',
          submitText: 'Save',
          fields: [
            CustomTextFormField(
              controller: modeController,
              labelText: 'Mode of Contact',
            ),
            DatePickerFormField(
              selectedDate: contactDate,
              labelText: 'Date',
              firstDate: DateTime(2000),
              onDateSelected: (date) =>
                  setDialogState(() => contactDate = date),
            ),
            CustomTextFormField(
              controller: descriptionController,
              labelText: 'Description',
              maxLines: 3,
            ),
          ],
          onSubmit: () async {
            try {
              await _apiService.createContact({
                'alumni': int.parse(widget.userId.toString()),
                'date':
                    '${contactDate.year}-${contactDate.month.toString().padLeft(2, '0')}-${contactDate.day.toString().padLeft(2, '0')}',
                'mode_of_contact': modeController.text,
                'description': descriptionController.text,
              });
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              await _loadPreviousContacts();
            } catch (e) {
              if (!dialogContext.mounted) return;
              AppSnackBar.show(dialogContext, 'Failed to log contact: $e',
                  isError: true);
            }
          },
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => FormDialog(
        title: 'Delete Alumni',
        submitText: 'Delete',
        fields: [
          Text(
            'Are you sure you want to delete ${userData['name'] ?? 'this alumni'}? This cannot be undone.',
          ),
        ],
        onSubmit: () async {
          try {
            await _apiService.deleteAlumni(int.parse(widget.userId.toString()));
            if (!dialogContext.mounted) return;
            Navigator.pop(dialogContext);
            if (!mounted) return;
            Navigator.pop(context, true);
          } catch (e) {
            if (!dialogContext.mounted) return;
            AppSnackBar.show(dialogContext, 'Failed to delete alumni: $e',
                isError: true);
          }
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (userData.isEmpty) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _model.tabBarController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            alignment: const AlignmentDirectional(0, -1),
            children: [
              Align(
                alignment: const AlignmentDirectional(0, -0.87),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShadowIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ShadowIconButton(
                        icon: Icons.edit,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/edit_profile',
                            arguments: {'userId': widget.userId.toString()},
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 100, 0, 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(0, 1),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 200, 0, 0),
                          child: Container(
                            width: double.infinity,
                            height: 800,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 4,
                                  color: Color(0x320E151B),
                                  offset: Offset(0.0, -2),
                                ),
                              ],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 12, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16, 0, 16, 0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userData['name'] ?? 'Alumni Name',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontFamily: 'Outfit',
                                                    letterSpacing: 0.0,
                                                  ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(0, 4, 0, 0),
                                              child: Text(
                                                userData['email'] ??
                                                    'Alumni Email',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      fontFamily: 'Outfit',
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _confirmDelete(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Delete User',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 12, 0, 0),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: const Alignment(0, 0),
                                            child: TabBar(
                                              labelColor: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              unselectedLabelColor:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withOpacity(0.5),
                                              labelStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    letterSpacing: 0.0,
                                                  ),
                                              indicatorColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              tabs: const [
                                                Tab(text: 'Alumni Info'),
                                                Tab(
                                                    text:
                                                        'Events Previously Attended'),
                                                Tab(text: 'Previous Contacts'),
                                              ],
                                              controller:
                                                  _model.tabBarController,
                                              onTap: (i) async {
                                                [
                                                  () async {},
                                                  _loadAttendedEvents,
                                                  _loadPreviousContacts,
                                                ][i]();
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: TabBarView(
                                              controller:
                                                  _model.tabBarController,
                                              children: [
                                                _buildPostsTab(context),
                                                _buildActivityTab(context),
                                                _buildContactTab(context),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      children: [
        _buildPostItem(
          context: context,
          phone: userData['phone'],
          email: userData['email'],
          socPoc: userData['soc_poc'],
          availability: userData['availability'],
          timeToContactFrom: userData['time_to_contact_from'],
          timeToContactTo: userData['time_to_contact_to'],
          country: userData['country'],
          priorCourse: userData['prior_course'],
          yearOfGraduation: userData['year_of_graduation']?.toString(),
          company: userData['company'],
          areaOfExpertise:
              List<String>.from(userData['area_of_expertise'] ?? []),
        ),
      ],
    );
  }

  Widget _buildActivityTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Events Attended',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _showMarkAttendedDialog,
                icon: const Icon(Icons.add),
                label: const Text('Mark Attended'),
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncListView<dynamic>(
            isLoading: _eventsLoading,
            items: _attendedEvents,
            emptyText: 'No events attended yet',
            itemBuilder: (context, item) => _buildAttendedEventCard(item),
          ),
        ),
      ],
    );
  }

  Widget _buildContactTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Previous Contacts',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: _showLogContactDialog,
                icon: const Icon(Icons.add),
                label: const Text('Log Contact'),
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncListView<dynamic>(
            isLoading: _contactsLoading,
            items: _previousContacts,
            emptyText: 'No previous contacts logged yet',
            itemBuilder: (context, item) => _buildContactCard(item),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendedEventCard(Map<String, dynamic> attendance) {
    final event = attendance['event_detail'] as Map<String, dynamic>?;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
      child: AppCard(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event?['name'] ?? 'Unknown Event',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Event date: ${event?['date'] ?? 'Unknown'}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              'Attended on: ${attendance['attended_on'] ?? 'Unknown'}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    final contactedBy = contact['contacted_by'] as Map<String, dynamic>?;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
      child: AppCard(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact['mode_of_contact'] ?? 'Unknown',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              contact['description'] ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${contact['date'] ?? ''} · Contacted by: ${contactedBy?['username'] ?? 'Unknown'}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostItem({
    required BuildContext context,
    String? phone,
    String? email,
    String? socPoc,
    String? availability,
    String? timeToContactFrom,
    String? timeToContactTo,
    String? country,
    String? priorCourse,
    String? yearOfGraduation,
    String? company,
    List<String>? areaOfExpertise,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (phone != null)
            Text(
              'Phone: $phone',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (email != null)
            Text(
              'Email: $email',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (socPoc != null)
            Text(
              'S.O.C POC: $socPoc',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (availability != null)
            Text(
              'Availability: $availability',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (timeToContactFrom != null && timeToContactTo != null)
            Text(
              'Contact Time: $timeToContactFrom - $timeToContactTo',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (country != null)
            Text(
              'Country: $country',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (priorCourse != null)
            Text(
              'Prior Course: $priorCourse',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (yearOfGraduation != null)
            Text(
              'Year of Graduation: $yearOfGraduation',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (company != null)
            Text(
              'Company: $company',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (areaOfExpertise != null && areaOfExpertise.isNotEmpty)
            Text(
              'Area of Expertise: ${areaOfExpertise.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

}
