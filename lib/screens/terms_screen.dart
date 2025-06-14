// FILE: terms_screen.dart
import 'package:flutter/material.dart';
// Import the LessonScreen which is the target destination when a term is tapped
import 'lesson_screen.dart';

// --- Colors defined for the Terms Screen Style ---
// These colors should ideally be part of a central theme file,
// but are included here for self-containment of the screen code.
const Color styleFormBgColor = Color(0xFFEDDCD9); // Background color for the term cards
const Color stylePrimaryTextColor = Color(0xFF264143); // Color for text, card borders, and AppBar icons/title
const Color styleShadowColor = Color(0xFFE99F4C); // Color for the hard shadow effect on cards
const Color styleScreenBgColor = Color(0xFFFDF6F0); // Background color for the screen itself
// --- End Color Definitions ---

/// TermsScreen displays selectable term cards (e.g., Term 1, Term 2) for a given year.
/// Tapping a term card navigates to the LessonScreen for that specific year and term.
class TermsScreen extends StatelessWidget {
  /// The academic year passed to this screen (e.g., "Year 10").
  final String year;

  /// Creates a TermsScreen.
  ///
  /// Requires the [year] string to be displayed in the AppBar and passed along.
  const TermsScreen({
    Key? key,
    required this.year,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Apply the specific background color for this screen style
      backgroundColor: styleScreenBgColor,
      appBar: AppBar(
        // Display the passed 'year' in the title
        title: Text(
          year,
          style: const TextStyle(
            color: stylePrimaryTextColor, // Use the defined primary text color
            fontWeight: FontWeight.w600, // Semi-bold weight for the title
          ),
        ),
        // Style the AppBar to match the screen's aesthetic
        backgroundColor: styleScreenBgColor, // Match the scaffold background
        elevation: 0, // No shadow for a flat look
        // Ensure the back button and any other icons use the primary text color
        iconTheme: const IconThemeData(
          color: stylePrimaryTextColor,
        ),
        // Custom back button consistent with the style
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), // Specific icon and size
          tooltip: 'Back', // Accessibility feature
          onPressed: () => Navigator.of(context).pop(), // Standard back navigation
        ),
      ),
      // Use SafeArea to avoid intrusions like notches or system bars
      body: SafeArea(
        child: Padding(
          // Consistent padding around the main content area
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          // Use a Row to display the two term cards side-by-side
          child: Row(
            children: [
              // Left card (Term 1) - Expanded takes half the available width
              Expanded(
                child: StyledTermCard(
                  // Navigate to the LessonScreen, passing the year and "Term 1"
                  onTap: () => _navigateToLessons(context, 'Term 1'),
                  label: 'Term 1', // Text displayed on the card
                ),
              ),
              // Spacing between the two cards
              const SizedBox(width: 20),
              // Right card (Term 2) - Expanded takes the other half
              Expanded(
                child: StyledTermCard(
                  // Navigate to the LessonScreen, passing the year and "Term 2"
                  onTap: () => _navigateToLessons(context, 'Term 2'),
                  label: 'Term 2', // Text displayed on the card
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handles navigation from this screen to the [LessonScreen].
  ///
  /// It uses a [PageRouteBuilder] for a custom slide transition animation.
  /// Passes the [year] and the selected [term] to the [LessonScreen].
  void _navigateToLessons(BuildContext context, String term) {
    Navigator.push(
      context,
      PageRouteBuilder(
        // The destination screen is LessonScreen
        pageBuilder: (context, animation, secondaryAnimation) =>
            LessonScreen(
              year: year,  // Pass the current year
              term: term,   // Pass the selected term ('Term 1' or 'Term 2')
            ),
        // Define the transition animation (slide in from the right)
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Define the starting offset (off-screen to the right)
          const begin = Offset(1.0, 0.0);
          // Define the ending offset (on-screen)
          const end = Offset.zero;
          // Define the animation curve for easing
          const curve = Curves.easeOutCubic;
          // Combine the offset tween with the curve
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          // Apply the slide transition driven by the animation controller
          return SlideTransition(
            position: animation.drive(tween),
            child: child, // The child is the LessonScreen being built
          );
        },
        // Set the duration of the transition animation
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}


/// A custom card widget specifically styled for the TermsScreen.
///
/// Features a hard shadow and a subtle press-down effect using Transform.translate.
class StyledTermCard extends StatefulWidget {
  /// The callback function executed when the card is tapped.
  final VoidCallback onTap;
  /// The text label displayed prominently on the card.
  final String label;

  /// Creates a StyledTermCard.
  const StyledTermCard({
    Key? key,
    required this.onTap,
    required this.label,
  }) : super(key: key);

  @override
  State<StyledTermCard> createState() => _StyledTermCardState();
}

/// The state associated with [StyledTermCard] to manage the press effect.
class _StyledTermCardState extends State<StyledTermCard> {
  /// Tracks whether the card is currently being pressed down.
  bool _isPressed = false;

  // --- Shadow Definitions for Normal and Pressed States ---
  // These create the distinct hard shadow effect.
  static const List<BoxShadow> _normalShadow = [
    BoxShadow(
      color: styleShadowColor, // Use the defined shadow color
      offset: Offset(3.0, 4.0), // Offset slightly down and right
      blurRadius: 0.0, // No blur for a hard edge
      spreadRadius: 1.0, // Slight spread
    ),
  ];
  static const List<BoxShadow> _pressedShadow = [
    BoxShadow(
      color: styleShadowColor,
      offset: Offset(1.0, 2.0), // Reduced offset when pressed
      blurRadius: 0.0,
      spreadRadius: 0.0, // No spread when pressed
    ),
  ];
  // --- End Shadow Definitions ---

  // --- Vertical Offset for Press Animation ---
  // Moves the card down slightly when pressed.
  static const _pressOffset = Offset(0, 4.0); // Translate 4 pixels down

  // --- Event Handlers for Gesture Detection ---
  void _handleTapDown(TapDownDetails details) {
    // When the user touches down, set the state to pressed.
    if (mounted) { // Ensure the widget is still in the tree
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    // When the user lifts their finger up after a tap:
    if (mounted) {
      // Set the state back to not pressed.
      setState(() => _isPressed = false);
      // Execute the onTap callback provided to the widget.
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    // If the tap is cancelled (e.g., user drags finger away):
    if (mounted) {
      // Set the state back to not pressed.
      setState(() => _isPressed = false);
    }
  }
  // --- End Event Handlers ---

  @override
  Widget build(BuildContext context) {
    // Determine which shadow list to use based on the current press state.
    final List<BoxShadow> currentShadow = _isPressed ? _pressedShadow : _normalShadow;
    // Determine the offset for translation based on the press state.
    final Offset currentOffset = _isPressed ? _pressOffset : Offset.zero;

    // Use GestureDetector to detect tap events and manage press state.
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      // Use Transform.translate to apply the press-down effect.
      child: Transform.translate(
        offset: currentOffset, // Apply the calculated offset
        // Use DecoratedBox for efficient application of background, border, and shadow.
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Apply the card background color
            color: styleFormBgColor,
            // Define the border rounding
            borderRadius: BorderRadius.circular(10.0),
            // Apply the border style
            border: Border.all(
              color: stylePrimaryTextColor, // Use the defined border color
              width: 2.0, // Set border thickness
            ),
            // Apply the currently selected shadow (normal or pressed)
            boxShadow: currentShadow,
          ),
          // Use a Container inside DecoratedBox primarily for sizing and content alignment.
          child: Container(
            // Give the card a fixed height (adjust as needed for your design)
            height: 180,
            // Center the content (the text label) within the card
            alignment: Alignment.center,
            // Add padding inside the card borders
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            // Display the label text
            child: Text(
              widget.label,
              textAlign: TextAlign.center, // Center the text horizontally
              style: const TextStyle(
                fontSize: 24, // Larger font size for the term label
                fontWeight: FontWeight.w700, // Bold weight for emphasis
                color: stylePrimaryTextColor, // Use the defined text color
              ),
            ),
          ),
        ),
      ),
    );
  }
}