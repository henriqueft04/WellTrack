import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:welltrack/pages/login_page.dart';
import 'package:welltrack/pages/home_page.dart';
import 'package:welltrack/components/email_pass.dart';
import 'package:welltrack/controllers/sign_up_controller.dart';
import 'package:sign_button/sign_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final SignUpController signUpController = SignUpController();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      bool success = await signUpController.signInWithGoogle();
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed in with Google successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to home page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
            (route) => false, // Remove all previous routes
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google sign in failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget googleSignInButton() {
    return SignInButton(
      buttonType: ButtonType.google,
      onPressed: _isLoading ? null : _handleGoogleSignIn,
      buttonSize: ButtonSize.large,
    );
  }

  void validateEmail(String email) {
    // Email validation is handled in the EmailPass component
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: HexColor("#CDEDFD"),
        body: Stack(
          children: [
            // Plants image at the very top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/Images/plants2.png',
                scale: 1,
                width: double.infinity,
              ),
            ),
            // Main content
            ListView(
              padding: const EdgeInsets.fromLTRB(0, 400, 0, 0),
              shrinkWrap: true,
              reverse: true,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 535,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: HexColor("#ffffff"),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            EmailPass(
                              title: "Sign Up",
                              buttonText: "Create Account",
                              showBackButton: true,
                              showNameField: true,
                              onBackPressed: () => Navigator.pop(context),
                              onSubmit: (email, password, name) async {
                                // Show loading
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  final result = await signUpController.registerUser(
                                    email,
                                    password,
                                    name: name,
                                  );

                                  // Hide loading
                                  if (mounted) Navigator.pop(this.context);

                                  if (result['success']) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                          backgroundColor: HexColor("#DEC5E3"),
                                        ),
                                      );
                                      
                                      // Navigate to home page
                                      Navigator.pushAndRemoveUntil(
                                        this.context,
                                        MaterialPageRoute(
                                          builder: (context) => const HomePage(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  } else {
                                    // Check if email already exists
                                    if (result['emailExists'] == true) {
                                      if (mounted) _showEmailExistsDialog(this.context, email);
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(this.context).showSnackBar(
                                          SnackBar(
                                            content: Text(result['message']),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                } catch (e) {
                                  // Hide loading
                                  if (mounted) Navigator.pop(this.context);
                                  
                                  if (mounted) {
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            // Google Sign In Button
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [googleSignInButton()],
                              ),
                            ),
                            // Navigation to Login
                            Padding(
                              padding: const EdgeInsets.fromLTRB(35, 0, 35, 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: HexColor("#8d8d8d"),
                                    ),
                                  ),
                                  TextButton(
                                    child: Text(
                                      "Log In",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: HexColor("#44564a"),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEmailExistsDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Already Registered'),
        content: Text(
          'The email $email is already registered.\n\nWould you like to log in instead?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Go to Login'),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
