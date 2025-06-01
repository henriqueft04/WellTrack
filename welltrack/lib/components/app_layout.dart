import 'package:flutter/material.dart';

/// Base layout component that provides consistent structure across all pages
/// Structure: Logo -> Page Title -> Content -> Navbar
class AppLayout extends StatelessWidget {
  final String pageTitle;
  final Widget content;
  final bool showLogo;
  final bool isMainPage;
  final Widget? bottomNavigationBar;

  const AppLayout({
    super.key,
    required this.pageTitle,
    required this.content,
    this.showLogo = true,
    this.isMainPage = false,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: Column(
          children: [
            // Logo section
            if (showLogo)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Image.asset(
                  'lib/images/logo.png',
                  height: 60,
                ),
              ),
            
            // Page title section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              width: double.infinity,
              child: Text(
                pageTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: showLogo ? TextAlign.center : TextAlign.left,
              ),
            ),
            
            // Content section
            Expanded(
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}

class PageWrapper extends StatelessWidget {
  final Widget child;
  final int? currentIndex;
  final Function(int)? onNavigationTap;

  const PageWrapper({
    super.key,
    required this.child,
    this.currentIndex,
    this.onNavigationTap,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
} 