import 'package:flutter/material.dart';
// Ensure this import points correctly to YOUR HomeScreen file
import 'home_screen.dart'; // Or the correct path in your project

//============================================================
// Login Screen Implementation (Final Version - Standalone Widget)
//============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Focus Nodes
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // State for focus/press effects
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isButtonPressed = false;

  // --- Define colors based on the React CSS ---
  static const Color formBgColor = Color(0xFFEDDCD9); // #EDDCD9
  static const Color primaryTextColor = Color(0xFF264143); // #264143
  static const Color shadowColor = Color(0xFFE99F4C); // #E99F4C
  static const Color buttonBgColor = Color(0xFFDE5499); // #DE5499
  static const Color screenBgColor = Color(0xFFFDF6F0); // Light complementary background
  static const Color inputFillColor = Colors.white; // Input background
  // --- End color definitions ---

  // --- Define Shadow Styles ---
  static const List<BoxShadow> normalInputShadow = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(3.0, 4.0), // dx=3, dy=4
      blurRadius: 0.0,
      spreadRadius: 1.0, // spread=1
    ),
  ];
  static const List<BoxShadow> focusedInputShadow = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(1.0, 2.0), // dx=1, dy=2
      blurRadius: 0.0,
      spreadRadius: 0.0, // spread=0
    ),
  ];
  static const List<BoxShadow> normalButtonShadow = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(3.0, 3.0), // dx=3, dy=3
      blurRadius: 0.0,
      spreadRadius: 0.0, // spread=0
    ),
  ];
  static const List<BoxShadow> pressedButtonShadow = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(1.0, 2.0), // dx=1, dy=2
      blurRadius: 0.0,
      spreadRadius: 0.0, // spread=0
    ),
  ];
  // --- End Shadow Styles ---

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Keep animation from original code if different
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn, // Keep animation curve from original code if different
      ),
    );

    // Add listeners to focus nodes
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);

    _animationController.forward();
  }

  void _onFocusChange() {
    // Update state based on focus node's hasFocus property
    if (mounted) {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    // Remove listeners and dispose focus nodes
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double formMaxWidth = 350.0;
    const pressOffset = Offset(0, 4.0); // translateY(4px)

    return Scaffold(
      // Consider setting backgroundColor here if needed, otherwise default is fine
      // backgroundColor: screenBgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: FadeTransition( // Keep FadeTransition if it was in original or desired
              opacity: _fadeAnimation,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: formMaxWidth),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  decoration: BoxDecoration(
                    color: formBgColor,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: primaryTextColor,
                      width: 2.0,
                    ),
                    boxShadow: const [ // Shadow for the form container
                      BoxShadow(
                        color: shadowColor,
                        offset: Offset(3.0, 4.0),
                        blurRadius: 0.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text( // Title
                          'SIGN IN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w900,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 30.0),

                        // --- Email Input Group ---
                        _buildStyledInputGroup(
                          label: 'Email',
                          controller: _emailController,
                          hint: 'Enter your email',
                          focusNode: _emailFocusNode,
                          isFocused: _isEmailFocused,
                          isObscure: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),

                        // --- Password Input Group ---
                        _buildStyledInputGroup(
                          label: 'Password',
                          controller: _passwordController,
                          hint: 'Enter your password',
                          focusNode: _passwordFocusNode,
                          isFocused: _isPasswordFocused,
                          isObscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 35.0),

                        // --- Sign In Button ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: GestureDetector(
                            onTapDown: (_) {
                              if(mounted) setState(() => _isButtonPressed = true);
                            },
                            onTapUp: (_) {
                              if(mounted) setState(() => _isButtonPressed = false);
                            },
                            onTapCancel: () {
                              if(mounted) setState(() => _isButtonPressed = false);
                            },
                            child: Transform.translate(
                              offset: _isButtonPressed ? pressOffset : Offset.zero,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  boxShadow: _isButtonPressed ? pressedButtonShadow : normalButtonShadow,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ElevatedButton(
                                  onPressed: _login, // Action triggers here
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonBgColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    minimumSize: const Size(double.infinity, 50),
                                    elevation: 0,
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  child: const Text(
                                    'SIGN IN',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ), // --- End Sign In Button ---
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for styled input fields
  Widget _buildStyledInputGroup({
    required String label,
    required TextEditingController controller,
    required String hint,
    required FocusNode focusNode,
    required bool isFocused,
    required bool isObscure,
    required FormFieldValidator<String> validator,
  }) {
    const pressOffset = Offset(0, 4.0);
    final inputDecoration = InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: primaryTextColor.withOpacity(0.6), fontSize: 15.0),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      filled: true,
      fillColor: inputFillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: primaryTextColor, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: primaryTextColor, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: primaryTextColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 14.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Transform.translate(
          offset: isFocused ? pressOffset : Offset.zero,
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: isFocused ? focusedInputShadow : normalInputShadow,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              obscureText: isObscure,
              validator: validator,
              style: const TextStyle(color: primaryTextColor, fontSize: 15.0),
              decoration: inputDecoration,
              cursorColor: primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  // Login action - Preserves ORIGINAL navigation logic
  void _login() {
    // Unfocus fields for visual consistency
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();

    if (!mounted) return; // Safety check

    if (_formKey.currentState!.validate()) {
      // Original logic used print statements, kept for consistency
      print('Email: ${_emailController.text}'); // Changed from username
      print('Password: ${_passwordController.text}');

      // *** THIS IS THE ORIGINAL NAVIGATION LOGIC FROM YOUR FIRST CODE ***
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const HomeScreen(), // <<< Navigates to YOUR HomeScreen
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOutCubic; // Use original curve
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500), // Use original duration
        ),
      );
      // *** END OF ORIGINAL NAVIGATION LOGIC ***

    } else {
      print("Form validation failed");
    }
  }
}