import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:welltrack/pages/login_page.dart';
import 'package:welltrack/pages/home_page.dart';

class EmailPass extends StatefulWidget {
  final String title;
  final String buttonText;
  final VoidCallback? onBackPressed;
  final Function(String email, String password, String? name)? onSubmit;
  final bool showBackButton;
  final bool showNameField;

  const EmailPass({
    super.key,
    required this.title,
    required this.buttonText,
    this.onBackPressed,
    this.onSubmit,
    this.showBackButton = true,
    this.showNameField = false,
  });

  @override
  State<EmailPass> createState() => _EmailPassState();
}

class _EmailPassState extends State<EmailPass> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String _errorMessage = "";

  void validateEmail(String email) {
    if (!email.contains('@')) {
      setState(() {
        _errorMessage = "Please enter a valid email";
      });
    } else {
      setState(() {
        _errorMessage = "";
      });
    }
  }

  Widget myButton({
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor("#CDEDFD"),
          foregroundColor: Colors.white,
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
      child: Column(
        children: [
          Row(
            children: [
              if (widget.showBackButton)
                GestureDetector(
                  onTap: widget.onBackPressed ?? () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              if (widget.showBackButton) const SizedBox(width: 67),
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#4f4f4f"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Input (conditionally shown)
                if (widget.showNameField) ...[
                  Text(
                    "Name",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: HexColor("#8d8d8d"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    cursorColor: HexColor("#4f4f4f"),
                    decoration: InputDecoration(
                      hintText: "Your full name",
                      fillColor: HexColor("#f0f3f1"),
                      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 15,
                        color: HexColor("#8d8d8d"),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                
                // Email Input
                Text(
                  "Email",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: HexColor("#8d8d8d"),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  onChanged: (value) {
                    validateEmail(value);
                  },
                  cursorColor: HexColor("#4f4f4f"),
                  decoration: InputDecoration(
                    hintText: "hello@gmail.com",
                    fillColor: HexColor("#f0f3f1"),
                    contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      color: HexColor("#8d8d8d"),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Text(
                    _errorMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Password Input
                Text(
                  "Password",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: HexColor("#8d8d8d"),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  cursorColor: HexColor("#4f4f4f"),
                  decoration: InputDecoration(
                    hintText: "*************",
                    fillColor: HexColor("#f0f3f1"),
                    contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      color: HexColor("#8d8d8d"),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                // Submit Button
                myButton(
                  buttonText: widget.buttonText,
                  onPressed: () {
                    bool isValid = emailController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty &&
                        _errorMessage.isEmpty;
                    
                    // If name field is shown, validate it too
                    if (widget.showNameField) {
                      isValid = isValid && nameController.text.isNotEmpty;
                    }

                    if (isValid) {
                      widget.onSubmit?.call(
                        emailController.text,
                        passwordController.text,
                        widget.showNameField ? nameController.text : null,
                      );
                    } else {
                      String errorMsg = 'Please fill all fields correctly';
                      if (widget.showNameField && nameController.text.isEmpty) {
                        errorMsg = 'Please enter your name';
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMsg),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}