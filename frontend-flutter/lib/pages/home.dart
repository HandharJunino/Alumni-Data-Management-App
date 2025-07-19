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
  final availabilityController = TextEditingController();
  final countryController = TextEditingController();
  final priorCourseController = TextEditingController();
  final yearController = TextEditingController();
  final employerController = TextEditingController();
  final interestsController = TextEditingController();
  final eventName = TextEditingController();
  final eventDescription = TextEditingController();
  TimeOfDay fromTime = TimeOfDay.now();
  TimeOfDay toTime = TimeOfDay.now();

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
    availabilityController.dispose();
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
      //print(e);
      _showError('Error loading alumni: $e');
    }
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _apiService.getEventsList();
      setState(() => _eventsList = events);
    } catch (e) {
      //print(e);
      _showError('Error loading events: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_eventsList.isEmpty) {
      return Center(
        child: Text(
          'No events found',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    return SizedBox(
      height: 170, // Fixed height for the scrolling container
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: _eventsList.length,
        itemBuilder: (context, index) => _buildEventCard(_eventsList[index]),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12),
      child: Container(
        width: 160,
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x34090F13),
              offset: Offset(0.0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
      ),
    );
  }

  Widget _buildAlumniList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_alumniList.isEmpty) {
      return Center(
        child: Text(
          'No alumni found',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _alumniList.length,
      itemBuilder: (context, index) {
        final alumni = _alumniList[index];
        return AlumniListItem(
          alumni: alumni,
          onView: () => Navigator.pushNamed(
            context,
            '/user_profile',
            arguments: {'userId': alumni['id']},
          ),
          onEdit: () => Navigator.pushNamed(
            context,
            '/edit_profile',
            arguments: {'userId': alumni['id']},
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: FaIcon(
              FontAwesomeIcons.adn,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(0, 0, 100, 100),
                items: [
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.brightness_6),
                      title: Text('Toggle Theme'),
                      onTap: () {
                        // Toggle the theme mode
                        Navigator.pop(context);
                        Provider.of<ThemeNotifier>(context, listen: false)
                            .toggleTheme();
                      },
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                      onTap: () {
                        Navigator.pop(context);
                        // Handle logout logic here
                        _authService.logout();
                        Navigator.pushNamed(context, '/auth');
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          title: Text(
            'Alumni Network',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.add_circle,
                color: Theme.of(context).appBarTheme.iconTheme?.color,
                size: 24,
              ),
              onPressed: () {
                double screenWidth = MediaQuery.of(context).size.width;

                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    screenWidth - 200,
                    kToolbarHeight,
                    screenWidth,
                    kToolbarHeight + 200,
                  ),
                  items: [
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.person_add),
                        title: Text('Add Member'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Add Member'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Name',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: phoneController,
                                        decoration: InputDecoration(
                                          labelText: 'Phone',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: socController,
                                        decoration: InputDecoration(
                                          labelText: 'SOC Point Of Contact',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      DropdownButtonFormField<String>(
                                        value: availabilityController
                                                .text.isNotEmpty
                                            ? availabilityController.text
                                            : null,
                                        decoration: InputDecoration(
                                          labelText: 'Availability',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: 'In-person',
                                            child: Text('In-person'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Online',
                                            child: Text('Online'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Unavailable',
                                            child: Text('Unavailable'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            availabilityController.text =
                                                value!;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Time to Contact From',
                                          border: OutlineInputBorder(),
                                          suffixIcon: Icon(Icons.access_time),
                                        ),
                                        readOnly: true,
                                        controller: TextEditingController(
                                          text: fromTime.format(context),
                                        ),
                                        onTap: () async {
                                          final TimeOfDay? picked =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: fromTime,
                                          );
                                          if (picked != null &&
                                              picked != fromTime) {
                                            setState(() {
                                              fromTime = picked;
                                            });
                                          }
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Time to Contact To',
                                          border: OutlineInputBorder(),
                                          suffixIcon: Icon(Icons.access_time),
                                        ),
                                        readOnly: true,
                                        controller: TextEditingController(
                                          text: toTime.format(context),
                                        ),
                                        onTap: () async {
                                          final TimeOfDay? picked =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: toTime,
                                          );
                                          if (picked != null &&
                                              picked != toTime) {
                                            setState(() {
                                              toTime = picked;
                                            });
                                          }
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: countryController,
                                        decoration: InputDecoration(
                                          labelText: 'Country',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: priorCourseController,
                                        decoration: InputDecoration(
                                          labelText: 'Prior Course',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: yearController,
                                        decoration: InputDecoration(
                                          labelText: 'Year Of Graduation',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: employerController,
                                        decoration: InputDecoration(
                                          labelText: 'Current Employer',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      TextFormField(
                                        controller: interestsController,
                                        decoration: InputDecoration(
                                          labelText: 'Areas of Interest',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      DropdownButtonFormField<String>(
                                        value:
                                            interestsController.text.isNotEmpty
                                                ? interestsController.text
                                                : null,
                                        decoration: InputDecoration(
                                          labelText: 'Area of Expertise',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: 'AI & ML',
                                            child: Text('AI & ML'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Cloud Computing',
                                            child: Text('Cloud Computing'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Cyber Security',
                                            child: Text('Cyber Security'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Data Science',
                                            child: Text('Data Science'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Web Development',
                                            child: Text('Web Development'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Mobile Development',
                                            child: Text('Mobile Development'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Blockchain',
                                            child: Text('Blockchain'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'DevOps',
                                            child: Text('DevOps'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Networking',
                                            child: Text('Networking'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Internet of Things',
                                            child: Text('Internet of Things'),
                                          ),
                                          // Add more options as needed
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            interestsController.text = value!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final alumniData = {
                                        'name': nameController.text,
                                        'phone': phoneController.text,
                                        'email': emailController.text,
                                        'soc_poc': socController.text,
                                        'availability':
                                            availabilityController.text,
                                        'time_to_contact_from':
                                            '${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}:00',
                                        'time_to_contact_to':
                                            '${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}:00',
                                        'country': countryController.text,
                                        'prior_course':
                                            priorCourseController.text,
                                        'year_of_graduation':
                                            int.parse(yearController.text),
                                        'company': employerController.text,
                                        'area_of_expertise': [
                                          interestsController.text
                                        ],
                                      };
                                      try {
                                        await _apiService.createAlumni(
                                            alumniData); // Wait for the alumni to be created
                                        await _loadAlumni(); // Reload the alumni list
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Alumni added successfully!')),
                                        );
                                        Navigator.pop(
                                            context); // Close the dialog
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Failed to add alumni: $e')),
                                        );
                                      }
                                    },
                                    child: Text('Add'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.event),
                        title: Text('Add Event'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Add Event'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: eventName,
                                      decoration: InputDecoration(
                                        labelText: 'Event Name',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Event Date',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      readOnly: true,
                                      controller: TextEditingController(
                                        text:
                                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                                      ),
                                      onTap: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100, 12, 31),
                                        );
                                        if (picked != null &&
                                            picked != selectedDate) {
                                          setState(() => selectedDate = picked);
                                        }
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Time',
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.access_time),
                                      ),
                                      readOnly: true,
                                      controller: TextEditingController(
                                        text: selectedTime.format(context),
                                      ),
                                      onTap: () async {
                                        final TimeOfDay? picked =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: selectedTime,
                                        );
                                        if (picked != null &&
                                            picked != selectedTime) {
                                          setState(() => selectedTime = picked);
                                        }
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      controller: eventDescription,
                                      decoration: InputDecoration(
                                        labelText: 'Description',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      final eventData = {
                                        'name': eventName.text,
                                        'date':
                                            "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}", // Format: YYYY-MM-DD
                                        'time':
                                            "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00", // Format: hh:mm:ss,
                                        'description': eventDescription.text,
                                      };
                                      try {
                                        await _apiService.createEvent(
                                            eventData); // Wait for the event to be created
                                        await _loadEvents(); // Reload the events list
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Event added successfully!')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Failed to add event: $e')),
                                        );
                                      }
                                    },
                                    child: Text('Add'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
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
