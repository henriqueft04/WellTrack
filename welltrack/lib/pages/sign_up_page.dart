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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
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
                              onBackPressed: () => Navigator.pop(context),
                              onSubmit: (email, password) async {
                                // Show loading
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );

                                try {
                                  bool success = await signUpController.registerUser(
                                    email,
                                    password,
                                    userType: 'Patient', // Default user type
                                  );

                                  // Hide loading
                                  Navigator.pop(context);

                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Account created successfully!'),
                                        backgroundColor: HexColor("#DEC5E3"),
                                      ),
                                    );
                                    
                                    // Navigate to home page
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HomePage(),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to create account. Please try again.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // Hide loading
                                  Navigator.pop(context);
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
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
}
