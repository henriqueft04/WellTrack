import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:welltrack/main.dart';
import 'package:sign_button/sign_button.dart';
import 'package:welltrack/pages/sign_up_page.dart';
import 'package:welltrack/components/email_pass.dart';
import 'package:welltrack/controllers/sign_up_controller.dart';
import 'package:welltrack/components/main_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _userId;
  bool _isLoading = false;
  final SignUpController authController = SignUpController();

  @override
  void initState() {
    super.initState();

    setState(() {
      _userId = supabase.auth.currentUser?.id;
    });

    supabase.auth.onAuthStateChange.listen((event) {
      if (mounted) {
        setState(() {
          _userId = event.session?.user.id;
          _isLoading = false;
        });
        
        if (_userId != null && !_isLoading) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation(initialIndex: 0)),
            (route) => false,
          );
        }
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      bool success = await authController.signInWithGoogle();
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signed in with Google successfully!'),
              backgroundColor: HexColor("#DEC5E3"),
            ),
          );
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigation(initialIndex: 0),
            ),
            (route) => false,
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

  Future<void> _handleSignOut() async {
    await supabase.auth.signOut();
  }

  Widget googleSignInButton() {
    return SignInButton(
      buttonType: ButtonType.google,
      onPressed: _isLoading ? null : _handleGoogleSignIn,
      buttonSize: ButtonSize.large,
    );
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(title: Text(message));
      },
    );
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
                              title: "Log In",
                              buttonText: "Sign In",
                              showBackButton: false,
                              showNameField: false, // No name field for login
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
                                  final result = await authController.signInUser(email, password);

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
                                          builder: (context) => const MainNavigation(initialIndex: 0),
                                        ),
                                        (route) => false, // Remove all previous routes
                                      );
                                    }
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
                            // Navigation to Sign Up
                            Padding(
                              padding: const EdgeInsets.fromLTRB(35, 0, 35, 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: HexColor("#8d8d8d"),
                                    ),
                                  ),
                                  TextButton(
                                    child: Text(
                                      "Sign Up",
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: HexColor("#44564a"),
                                      ),
                                    ),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SignUpPage(),
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
