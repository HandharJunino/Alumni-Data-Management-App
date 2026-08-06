import 'package:flutter/material.dart';
import 'package:alumni_app/models/auth_model.dart';
import 'package:alumni_app/functions/authentication.dart';
import 'package:alumni_app/components.dart';

class AuthPageWidget extends StatefulWidget {
  const AuthPageWidget({super.key});

  @override
  State<AuthPageWidget> createState() => _AuthPageWidgetState();
}

class _AuthPageWidgetState extends State<AuthPageWidget>
    with TickerProviderStateMixin {
  late AuthPageModel _model;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _model = AuthPageModel(vsync: this);
    _model.initState(context);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 44),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 602),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(
                                  'AlumniApp',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 602),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TabBar(
                                  controller: _model.tabBarController,
                                  isScrollable: true,
                                  labelColor:
                                      Theme.of(context).colorScheme.onSurface,
                                  unselectedLabelColor: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                      ),
                                  unselectedLabelStyle: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontFamily: 'Outfit',
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                  indicatorColor:
                                      Theme.of(context).colorScheme.primary,
                                  indicatorWeight: 4,
                                  tabs: const [
                                    Tab(text: 'Sign In'),
                                    Tab(text: 'Sign Up'),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 700,
                                child: TabBarView(
                                  controller: _model.tabBarController,
                                  children: [
                                    _buildSignInForm(context),
                                    _buildSignUpForm(context),
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
            if (MediaQuery.of(context).size.width > 800)
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    /*image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(
                        'https://images.unsplash.com/photo-1508385082359-f38ae991e8f2?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1374&q=80',
                      ),
                    ),*/
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              "Let's get started by filling out the form below.",
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontFamily: 'Outfit',
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 24),
            CustomTextFormField(
              controller: _model.emailAddressTextController,
              focusNode: _model.emailAddressFocusNode,
              labelText: 'Email',
              borderRadius: 40,
              borderColor: Theme.of(context).colorScheme.outline,
              contentPadding: const EdgeInsets.all(24),
              keyboardType: TextInputType.emailAddress,
              validator: _model.emailAddressTextControllerValidator,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _model.passwordTextController,
              focusNode: _model.passwordFocusNode,
              labelText: 'Password',
              borderRadius: 40,
              borderColor: Theme.of(context).colorScheme.outline,
              contentPadding: const EdgeInsets.all(24),
              obscureText: !_model.passwordVisibility,
              validator: _model.passwordTextControllerValidator,
              suffixIcon: IconButton(
                icon: Icon(
                  _model.passwordVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _model.passwordVisibility = !_model.passwordVisibility;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_model.emailAddressTextController.text.isEmpty ||
                    _model.passwordTextController.text.isEmpty) {
                  AppSnackBar.show(
                      context, 'Please enter both email and password',
                      isError: true);
                  return; // Stop execution if fields are empty
                }

                try {
                  // Call the login function
                  String? error = await _authService.loginUser(
                    _model.emailAddressTextController.text,
                    _model.passwordTextController.text,
                  );

                  if (!mounted) return;
                  if (error == null) {
                    // Login successful, navigate to home
                    Navigator.pushNamed(context, '/home');
                  } else {
                    AppSnackBar.show(context, error, isError: true);
                  }
                } catch (e) {
                  if (!mounted) return;
                  AppSnackBar.show(
                      context, 'An error occurred: ${e.toString()}',
                      isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: Text(
                'Sign In',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    TextEditingController emailController =
                        TextEditingController();
                    return FormDialog(
                      title: 'Forgot Password',
                      submitText: 'Submit',
                      fields: [
                        CustomTextFormField(
                          controller: emailController,
                          labelText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                      onSubmit: () async {
                        if (emailController.text.isEmpty) {
                          AppSnackBar.show(
                              dialogContext, 'Please enter your email',
                              isError: true);
                          return;
                        }

                        // Send forgot password request
                        bool success = await _authService
                                .forgotPassword(emailController.text) ==
                            null;

                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);

                        if (!mounted) return;
                        AppSnackBar.show(
                          context,
                          success
                              ? 'Password reset link sent to your email'
                              : 'Email not found',
                          isSuccess: success,
                          isError: !success,
                        );
                      },
                    );
                  },
                );
              },
              child: Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpForm(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              "Let's get started by filling out the form below.",
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontFamily: 'Outfit',
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 24),
            CustomTextFormField(
              controller: _model.userNameTextController,
              focusNode: _model.userNameFocusNode,
              labelText: 'Username',
              borderRadius: 40,
              borderColor: Theme.of(context).colorScheme.outline,
              contentPadding: const EdgeInsets.all(24),
              keyboardType: TextInputType.name,
              validator: _model.userNameTextControllerValidator,
            ),
            const SizedBox(height: 24),
            CustomTextFormField(
              controller: _model.emailAddressCreateTextController,
              focusNode: _model.emailAddressCreateFocusNode,
              labelText: 'Email',
              borderRadius: 40,
              borderColor: Theme.of(context).colorScheme.outline,
              contentPadding: const EdgeInsets.all(24),
              keyboardType: TextInputType.emailAddress,
              validator: _model.emailAddressCreateTextControllerValidator,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _model.passwordCreateTextController,
              focusNode: _model.passwordCreateFocusNode,
              labelText: 'Password',
              borderRadius: 40,
              borderColor: Theme.of(context).colorScheme.outline,
              contentPadding: const EdgeInsets.all(24),
              obscureText: !_model.passwordCreateVisibility,
              validator: _model.passwordCreateTextControllerValidator,
              suffixIcon: IconButton(
                icon: Icon(
                  _model.passwordCreateVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _model.passwordCreateVisibility =
                        !_model.passwordCreateVisibility;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _model.passwordConfirmTextController,
              focusNode: _model.passwordConfirmFocusNode,
              labelText: 'Confirm Password',
              borderRadius: 40,
              borderColor: Theme.of(context).colorScheme.outline,
              contentPadding: const EdgeInsets.all(24),
              obscureText: !_model.passwordConfirmVisibility,
              validator: _model.passwordConfirmTextControllerValidator,
              suffixIcon: IconButton(
                icon: Icon(
                  _model.passwordConfirmVisibility
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _model.passwordConfirmVisibility =
                        !_model.passwordConfirmVisibility;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_model.userNameTextController.text.isEmpty) {
                  AppSnackBar.show(context, 'Username cannot be empty!',
                      isError: true);
                  return;
                }
                if (_model.emailAddressCreateTextController.text.isEmpty) {
                  AppSnackBar.show(context, 'Email cannot be empty!',
                      isError: true);
                  return;
                }
                if (_model.passwordCreateTextController.text.isEmpty) {
                  AppSnackBar.show(context, 'Password cannot be empty!',
                      isError: true);
                  return;
                }
                if (_model.passwordConfirmTextController.text.isEmpty) {
                  AppSnackBar.show(
                      context, 'Confirm Password cannot be empty!',
                      isError: true);
                  return;
                }
                if (_model.passwordCreateTextController.text !=
                    _model.passwordConfirmTextController.text) {
                  AppSnackBar.show(context, 'Passwords don\'t match!',
                      isError: true);
                  return;
                }
                try {
                  String? errorMessage = await _authService.registerUser(
                    _model.userNameTextController.text,
                    _model.emailAddressCreateTextController.text,
                    _model.passwordCreateTextController.text,
                    _model.passwordConfirmTextController.text,
                  );
                  if (!mounted) return;
                  if (errorMessage == null) {
                    Navigator.pushNamed(context, '/home');
                  } else {
                    AppSnackBar.show(context, errorMessage, isError: true);
                  }
                } catch (e) {
                  if (!mounted) return;
                  AppSnackBar.show(context, e.toString(), isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: Text(
                'Create Account',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
