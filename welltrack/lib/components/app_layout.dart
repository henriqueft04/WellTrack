import 'package:flutter/material.dart';

/// Base layout component that provides consistent structure across all pages
/// Structure: Logo -> Page Title -> Content -> Navbar
class AppLayout extends StatelessWidget {
  final String pageTitle;
  final Widget content;
  final bool showLogo;
  final bool isMainPage;
  final Widget? bottomNavigationBar;
  final bool showBackButton;

  const AppLayout({
    super.key,
    required this.pageTitle,
    required this.content,
    this.showLogo = true,
    this.isMainPage = false,
    this.bottomNavigationBar,
    this.showBackButton = false,
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
            
            // Page title section with optional back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              width: double.infinity,
              child: Row(
                children: [
                  if (showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (showBackButton) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pageTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: showBackButton ? TextAlign.left : (showLogo ? TextAlign.center : TextAlign.left),
                    ),
                  ),
                ],
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

/// Wrapper component that ensures navbar is present on all pages
/// and provides navigation functionality
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