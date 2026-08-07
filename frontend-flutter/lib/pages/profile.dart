import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:alumni_app/models/profile_model.dart';
import 'package:alumni_app/animations.dart';
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

  final animationsMap = <String, AnimationInfo>{};

  final ApiService _apiService = ApiService();
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _model = UserProfileModel();

    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    )..addListener(() => setState(() {}));

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 80.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
    });
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _apiService.getUserDetails(widget.userId.toString());
      if (mounted) {
        setState(() {
          userData = data;
          print('Loaded user data: $userData');
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        // Use post-frame callback for showing SnackBar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading user data: $e')),
          );
        });
      }
    }
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
                                                  () async {},
                                                  () async {},
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
    return ListView(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: [
        _buildActivityItem(
          context,
          '4 hour session',
          'Scene Setup 101',
          '\$500',
        ),
        _buildActivityItem(
          context,
          '2 Week Intensive',
          'Adventure Photography',
          '\$2,000',
        ),
      ],
    );
  }

  Widget _buildContactTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: [
        _buildActivityItem(
          context,
          'Alumni S.O.C poc',
          'Alumni name',
          'Alumni email',
        )
      ],
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

  Widget _buildActivityItem(
    BuildContext context,
    String duration,
    String title,
    String price,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  duration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 0.0,
                      ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 8),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'Outfit',
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
                Text(
                  price,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'Outfit',
                        letterSpacing: 0.0,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
