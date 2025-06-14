import 'package:flutter/material.dart';
import 'terms_screen.dart'; // Assuming this screen exists and is correctly imported
import 'dart:async'; // Needed for Future.delayed if used (though likely removed)

// --- Colors from LoginScreen Style ---
const Color styleFormBgColor = Color(0xFFEDDCD9); // Card Background
const Color stylePrimaryTextColor = Color(0xFF264143); // Card Border, Text
const Color styleShadowColor = Color(0xFFE99F4C); // Card Shadow
// const Color styleButtonBgColor = Color(0xFFDE5499); // Not used directly here, but part of the theme
const Color styleScreenBgColor = Color(0xFFFDF6F0); // Screen Background
// const Color styleInputFillColor = Colors.white; // Not used here

// --- Main Screen Widget ---
class YearsScreen extends StatefulWidget {
  const YearsScreen({super.key});
  @override
  State<YearsScreen> createState() => _YearsScreenState();
}

class _YearsScreenState extends State<YearsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _loadAnimationController;

  // Data remains the same
  final List<Map<String, dynamic>> years = [
    {'year': 'Year 1', 'color': Colors.blue[400]!, 'icon': Icons.looks_one},
    {'year': 'Year 2', 'color': Colors.green[400]!, 'icon': Icons.looks_two},
    {'year': 'Year 3', 'color': Colors.orange[400]!, 'icon': Icons.looks_3},
    {'year': 'Year 4', 'color': Colors.red[400]!, 'icon': Icons.looks_4},
    {'year': 'Year 5', 'color': Colors.purple[300]!, 'icon': Icons.looks_5},
    {'year': 'Year 6', 'color': Colors.teal[300]!, 'icon': Icons.looks_6},
  ];

  @override
  void initState() {
    super.initState();
    // Initial load animation controller remains
    _loadAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900), // Keep original duration
    );
    _loadAnimationController.forward();
  }

  @override
  void dispose() {
    _loadAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const tabletBreakpoint = 600.0;
    final crossAxisCount = screenWidth > tabletBreakpoint ? 3 : 2;
    // Adjust aspect ratio if needed after visual changes
    const childAspectRatioValue = 0.9; // Might need adjustment for text
    const crossAxisSpacingValue = 25.0; // Adjusted spacing
    const mainAxisSpacingValue = 30.0;  // Adjusted spacing

    return Scaffold(
      // Apply the light screen background color
      backgroundColor: styleScreenBgColor,
      body: SafeArea(
        child: Padding(
          // Adjust padding if needed
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatioValue,
              crossAxisSpacing: crossAxisSpacingValue,
              mainAxisSpacing: mainAxisSpacingValue,
            ),
            itemCount: years.length,
            itemBuilder: (context, index) {
              // Keep the initial load animation structure
              return AnimatedBuilder(
                animation: _loadAnimationController,
                builder: (context, child) {
                  // Load animation logic remains the same
                  final delay = index * 0.08;
                  final start = delay.clamp(0.0, 0.8);
                  final end = (delay + 0.4).clamp(0.1, 1.0);
                  final slideAnimation = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
                      .animate(CurvedAnimation(parent: _loadAnimationController, curve: Interval(start, end, curve: Curves.easeOutCubic)));
                  final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                      .animate(CurvedAnimation(parent: _loadAnimationController, curve: Interval(start, end * 0.9, curve: Curves.easeOut)));
                  // Scale animation can be kept for load effect if desired, or removed
                  final scaleAnimation = Tween<double>(begin: 0.85, end: 1.0)
                      .animate(CurvedAnimation(parent: _loadAnimationController, curve: Interval(start, end, curve: Curves.easeOutBack)));

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: ScaleTransition( // Keep scale for load? Optional.
                      scale: scaleAnimation,
                      child: SlideTransition(
                        position: slideAnimation,
                        child: child, // This is the _YearCardWidget instance
                      ),
                    ),
                  );
                  /* // Simpler version without scale for load
                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                  */
                },
                // Pass data to the *newly styled* card widget
                child: _YearCardWidget(
                  year: years[index]['year'],
                  iconColor: years[index]['color'] as Color, // Keep original icon colors
                  icon: years[index]['icon'] as IconData,
                  onTap: () => _navigateToTerms(years[index]['year']), // Navigation stays
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Navigation Function remains the same
  void _navigateToTerms(String year) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TermsScreen(year: year),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); const end = Offset.zero; const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}


// --- REVISED: Year Card Widget to match Login Screen Style ---
class _YearCardWidget extends StatefulWidget {
  final String year;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  const _YearCardWidget({
    required this.year,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_YearCardWidget> createState() => _YearCardWidgetState();
}

class _YearCardWidgetState extends State<_YearCardWidget> {
  // Only need to track press state for transform/shadow
  bool _isPressed = false;

  // --- Shadow Definitions (Matching Login Style) ---
  static const List<BoxShadow> _normalShadow = [
    BoxShadow(
      color: styleShadowColor,
      offset: Offset(3.0, 4.0), // dx=3, dy=4
      blurRadius: 0.0,
      spreadRadius: 1.0, // spread=1
    ),
  ];
  static const List<BoxShadow> _pressedShadow = [
    BoxShadow(
      color: styleShadowColor,
      offset: Offset(1.0, 2.0), // dx=1, dy=2
      blurRadius: 0.0,
      spreadRadius: 0.0, // spread=0
    ),
  ];
  // --- End Shadow Definitions ---

  // --- Press Offset ---
  static const _pressOffset = Offset(0, 4.0); // translateY(4px)

  // --- Event Handlers (Simplified) ---
  void _handleTapDown(TapDownDetails details) {
    if (mounted) {
      setState(() {
        _isPressed = true; // Set pressed state for visual change
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (mounted) {
      // Reset visual state *before* triggering tap logic
      setState(() {
        _isPressed = false;
      });
      // Trigger the actual tap logic passed from parent
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    if (mounted) {
      setState(() {
        _isPressed = false; // Reset visual state
      });
    }
  }
  // --- End Event Handlers ---

  @override
  Widget build(BuildContext context) {
    // Determine current shadow based ONLY on press state
    final List<BoxShadow> currentShadow = _isPressed ? _pressedShadow : _normalShadow;

    // No MouseRegion needed for hover effects
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      // Actual onTap logic is in _handleTapUp via widget.onTap()

      child: Transform.translate(
        // Apply translation based on press state
        offset: _isPressed ? _pressOffset : Offset.zero,
        child: DecoratedBox( // Use DecoratedBox for styling
          decoration: BoxDecoration(
            color: styleFormBgColor, // Use the light pinkish background
            borderRadius: BorderRadius.circular(10.0), // Consistent rounding
            border: Border.all( // Apply the dark teal border
              color: stylePrimaryTextColor,
              width: 2.0,
            ),
            boxShadow: currentShadow, // Apply the dynamic hard shadow
          ),
          // No InkWell needed, remove splash/highlight
          // clipBehavior: Clip.antiAlias, // Not needed without InkWell
          child: Padding( // Add padding inside the card
            padding: const EdgeInsets.all(12.0),
            child: Column( // Use Column for Icon + Text
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              children: [
                Icon(
                  widget.icon,
                  size: 48, // Keep icon size or adjust as needed
                  color: widget.iconColor, // Use the color passed in
                ),
                const SizedBox(height: 10), // Space between icon and text
                Text(
                  widget.year,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: stylePrimaryTextColor, // Use dark teal text color
                    fontWeight: FontWeight.w600, // Match label weight from login
                    fontSize: 16, // Adjust size as needed
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}