import 'package:flutter/material.dart';
import 'package:smartlocker/screens/buyer/buyer_dashboard_screen.dart';
import 'package:smartlocker/screens/owner/owner_role_selection_screen.dart';
import 'package:smartlocker/services/auth_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/app_logo.dart';

enum UserType { owner, buyer }

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key, required this.userType});

  final UserType userType;

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _registerUsernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerFirstNameController = TextEditingController();
  final _registerLastNameController = TextEditingController();

  bool _loginLoading = false;
  bool _registerLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _registerFirstNameController.dispose();
    _registerLastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.header,
        elevation: 0,
        leading: const BackButton(color: AppColors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white70,
          indicatorColor: AppColors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'LOGIN'),
            Tab(text: 'REGISTER'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LoginForm(
            formKey: _loginFormKey,
            emailController: _loginEmailController,
            passwordController: _loginPasswordController,
            isLoading: _loginLoading,
            onSubmit: _handleLogin,
          ),
          _RegisterForm(
            formKey: _registerFormKey,
            usernameController: _registerUsernameController,
            emailController: _registerEmailController,
            passwordController: _registerPasswordController,
            confirmPasswordController: _registerConfirmPasswordController,
            firstNameController: _registerFirstNameController,
            lastNameController: _registerLastNameController,
            isLoading: _registerLoading,
            requireOwnerDetails: widget.userType == UserType.owner,
            onSubmit: _handleRegister,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _loginLoading = true);
    try {
      await AuthService.instance.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text.trim(),
      );
      if (!mounted) return;

      final destination = widget.userType == UserType.owner
          ? const OwnerRoleSelectionScreen()
          : const BuyerDashboardScreen();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => destination),
        (route) => false,
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Unexpected error: $error');
    } finally {
      if (mounted) {
        setState(() => _loginLoading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _registerLoading = true);
    try {
      await AuthService.instance.register(
        username: _registerUsernameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text.trim(),
        role:
            widget.userType == UserType.owner ? UserRole.owner : UserRole.buyer,
        firstName: widget.userType == UserType.owner
            ? _registerFirstNameController.text.trim()
            : null,
        lastName: widget.userType == UserType.owner
            ? _registerLastNameController.text.trim()
            : null,
      );
      _showMessage('Registration successful. Please login.');
      _tabController.animateTo(0);
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Unexpected error: $error');
    } finally {
      if (mounted) {
        setState(() => _registerLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.isLoading,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppFullLogo(),
            const SizedBox(height: 24),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FormField(
                    controller: emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: passwordController,
                    label: 'Password',
                    obscureText: true,
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.header,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('LOGIN',
                            style:
                                TextStyle(color: AppColors.black, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.firstNameController,
    required this.lastNameController,
    required this.onSubmit,
    required this.isLoading,
    required this.requireOwnerDetails,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool requireOwnerDetails;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppFullLogo(),
            const SizedBox(height: 24),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FormField(
                    controller: usernameController,
                    label: 'Username',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Username is required.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (requireOwnerDetails) ...[
                    _FormField(
                      controller: firstNameController,
                      label: 'First Name',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      controller: lastNameController,
                      label: 'Last Name',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _FormField(
                    controller: emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: passwordController,
                    label: 'Password',
                    obscureText: true,
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password.';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.header,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('REGISTER',
                            style:
                                TextStyle(color: AppColors.black, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
      ),
      validator: validator,
    );
  }
}

String? _emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required.';
  }
  final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,4}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? _passwordValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Password is required.';
  }
  if (value.trim().length < 6) {
    return 'Password must be at least 6 characters.';
  }
  return null;
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required.';
  }
  return null;
}
