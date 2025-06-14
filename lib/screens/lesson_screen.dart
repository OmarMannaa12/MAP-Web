// FILE: lesson_screen.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

// *** IMPORTANT: Make sure this path is correct for your project structure ***
import 'game_screen.dart'; // Ensure this points to your game screen file

// --- Constants and Theme ---

// Colors (Adapted from Login Screen & Duolingo Header)
const Color formBgColor = Color(0xFFEDDCD9);
const Color primaryTextColor = Color(0xFF264143); // Keep for dark text elements
const Color shadowColor = Color(0xFFE99F4C);
const Color buttonBgColor = Color(0xFFDE5499); // Lesson Node Ready Color
const Color screenBgColor = Color(0xFFFDF6F0); // Base background color
const Color inputFillColor = Colors.white;
const Color secondaryTextColor = Color(0xFF7d8c8d);

// Header Specific Colors (Inspired by Duolingo Green)
const Color headerGreenColor = Color(0xFF58CC02); // Vibrant Green
const Color headerGreenDarkerColor = Color(0xFF4CAF50); // Darker shade for button base/shadow
const Color headerTextColor = Colors.white; // White text on green

// Node Specific Colors
const Color lessonReadyColor = buttonBgColor;
const Color lessonReadyShadowColor = Color(0xFFBF407E);
const Color lessonCompletedColor = Color(0xFFFFAA5C);
const Color lessonCompletedShadowColor = shadowColor;
const Color lessonLockedColor = Color(0xFFE0E0E0);
const Color lessonLockedShadowColor = Color(0xFFBDBDBD);
const Color lessonLabelBgColor = inputFillColor;
const Color lessonLabelTextColor = primaryTextColor;
const Color nodeIconColor = Colors.white;
const Color lockedNodeIconColor = secondaryTextColor;
const Color trophyColor = Color(0xFFFFC107);

// Map Decoration Colors
const Color grassColor = Color(0xFF8BC34A);
const Color grassDarkerColor = Color(0xFF689F38);
const Color treeTrunkColor = Color(0xFF795548);
const Color treeLeavesColor = Color(0xFF4CAF50);
const Color xMarkColor = Color(0xFFD32F2F);

// Shadow for Pressed State Node/Button
const List<BoxShadow> pressedShadow = [
  BoxShadow( color: Color(0x66000000), offset: Offset(1.0, 1.0), blurRadius: 1.0, spreadRadius: 0.0),
];
// --- End Constants and Theme ---

// --- Mock Data ---
// (Keep the allSubjects list exactly as before)
final List<Map<String, dynamic>> allSubjects = [
  { 'name': 'Math', 'icon': Icons.calculate, 'lessons': List.generate(8, (i) => 'Algebra Basics ${i + 1}') },
  { 'name': 'Science', 'icon': Icons.science, 'lessons': List.generate(10, (i) => 'Biology Intro ${i + 1}') },
  { 'name': 'History', 'icon': Icons.history, 'lessons': List.generate(6, (i) => 'Ancient Civilizations ${i + 1}') },
  { 'name': 'Literature', 'icon': Icons.book, 'lessons': List.generate(12, (i) => 'Classic Novels ${i + 1}') },
];
// --- End Mock Data ---


// --- Main Screen Widget ---
class LessonScreen extends StatefulWidget {
  final String year;
  final String term;
  const LessonScreen({ super.key, required this.year, required this.term });
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> with SingleTickerProviderStateMixin {
  // State Variables
  late Map<String, dynamic> _selectedSubject;
  late List<String> _lessons;
  late Map<String, int> _lessonStates;
  final Map<String, GlobalKey> _lessonKeys = {};

  // Controllers
  late AnimationController _fadeAnimationController;
  final ScrollController _scrollController = ScrollController();

  // Animations
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeData();
    _startAnimations();
    _schedulePostFrameCallbacks();
  }

  void _initializeControllers() {
    _fadeAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(
        parent: _fadeAnimationController, curve: Curves.easeIn);
  }

  void _initializeData() {
    _selectedSubject = allSubjects.isNotEmpty ? allSubjects[0] : {};
    _updateLessonsAndStates();
  }

  void _startAnimations() {
    _fadeAnimationController.forward();
  }

  void _schedulePostFrameCallbacks() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLesson());
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- State Update Logic --- (Remains the same)
  void _updateLessonsAndStates() {
    _lessons = List<String>.from(_selectedSubject['lessons'] ?? []);
    _lessonStates = {}; _lessonKeys.clear();
    for (var lessonName in _lessons) { _lessonKeys[lessonName] = GlobalKey(); }
    bool firstReadyFound = false; int readyIndex = -1;
    for (int i = 0; i < _lessons.length; i++) {
      final lessonName = _lessons[i];
      if (i < 2) { _lessonStates[lessonName] = 2; }
      else if (!firstReadyFound) { _lessonStates[lessonName] = 1; readyIndex = i; firstReadyFound = true; }
      else { _lessonStates[lessonName] = 0; }
    }
    if (!firstReadyFound && _lessons.isNotEmpty) { _lessonStates[_lessons[0]] = 1; readyIndex = 0; }
    for(int i=0; i < _lessons.length; i++){
      final lessonName = _lessons[i];
      if(_lessonStates[lessonName] == 1 && i != readyIndex){ _lessonStates[lessonName] = 0; }
    }
    if (mounted) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLesson());
    }
  }

  // --- Scroll Logic --- (Remains the same)
  void _scrollToCurrentLesson() {
    String? currentLessonName;
    _lessonStates.forEach((name, state) { if (state == 1) { currentLessonName = name; } });
    if (currentLessonName != null && _lessonKeys[currentLessonName!] != null) {
      final key = _lessonKeys[currentLessonName!]!; final context = key.currentContext;
      if (context != null && _scrollController.hasClients) {
        Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut, alignment: 0.4);
      }
    }
  }

  // --- Navigation --- (Remains the same)
  void _navigateToGame(BuildContext context, String lessonName) {
    print("Navigating to Game Screen for lesson: $lessonName (Subject: ${_selectedSubject['name']}, Term: ${widget.term}, Year: ${widget.year})");
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0); var end = Offset.zero; var curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 500),
    ),
    );
  }

  // --- Modal Bottom Sheet Logic --- (Remains the same)
  void _showSubjectSelectionModal(BuildContext context) {
    showModalBottomSheet( context: context, backgroundColor: formBgColor.withOpacity(0.98), isScrollControlled: true,
        shape: const RoundedRectangleBorder( borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        builder: (BuildContext context) { return StatefulBuilder( builder: (BuildContext context, StateSetter setModalState) {
          return _buildSubjectSelectionContent(setModalState); }); });
  }

  Widget _buildSubjectSelectionContent(StateSetter setModalState) {
    return Padding( padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      child: Column( mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('SELECT SUBJECT', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w900, color: primaryTextColor)),
        const SizedBox(height: 20),
        Flexible( child: ListView.builder( shrinkWrap: true, itemCount: allSubjects.length,
          itemBuilder: (context, index) { final subject = allSubjects[index]; final bool isSelected = subject['name'] == _selectedSubject['name'];
          return ListTile( leading: Icon(subject['icon'] as IconData, color: isSelected ? buttonBgColor : secondaryTextColor, size: 24),
              title: Text(subject['name'] as String, style: TextStyle(color: isSelected ? buttonBgColor : primaryTextColor, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, fontSize: 16)),
              tileColor: isSelected ? buttonBgColor.withOpacity(0.1) : Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onTap: () { if (!isSelected) { setState(() { _selectedSubject = subject; _updateLessonsAndStates(); }); } Navigator.pop(context); }); },
        ),
        ), const SizedBox(height: 16), ],
      ),
    );
  }

  // --- Screen Build Method ---
  @override
  Widget build(BuildContext context) {
    final String currentSubjectName = _selectedSubject['name'] ?? 'Lessons';
    final String headerTitle = '$currentSubjectName - ${widget.term}'.toUpperCase(); // Use uppercase like Duolingo

    return Scaffold(
      backgroundColor: screenBgColor,
      // Remove AppBar
      // appBar: _buildAppBar(),
      body: SafeArea(
        child: Column( // Main layout: Header + Expanded Path
          children: [
            // --- Custom Header ---
            _CustomHeader(
              title: headerTitle,
              onBackPressed: () => Navigator.of(context).pop(),
              onRightButtonPressed: () => _showSubjectSelectionModal(context),
              // Replace with Guidebook functionality if needed later
              // onRightButtonPressed: () { /* TODO: Open Guidebook */ },
            ),

            // --- Lesson Path (Expanded to fill remaining space) ---
            Expanded(
              child: _lessons.isEmpty
                  ? const Center( child: Text( 'No lessons available yet.', style: TextStyle(color: secondaryTextColor, fontSize: 16)))
                  : FadeTransition(
                opacity: _fadeAnimation,
                child: _LessonPath( // Use the lesson path widget
                  lessons: _lessons,
                  lessonStates: _lessonStates,
                  lessonKeys: _lessonKeys,
                  scrollController: _scrollController,
                  onNavigate: _navigateToGame,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} // End _LessonScreenState


// --- UI Component Widgets ---

/// Custom Header Widget resembling Duolingo's section header.
class _CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onRightButtonPressed;
  // Could add more specific params like rightButtonIcon, rightButtonText if needed

  const _CustomHeader({
    required this.title,
    required this.onBackPressed,
    required this.onRightButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 12.0;
    const double verticalPadding = 10.0;
    const double borderRadius = 16.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0), // Inner padding for content
      decoration: BoxDecoration(
          color: headerGreenColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [ // Subtle shadow for depth
            BoxShadow(
              color: headerGreenDarkerColor.withOpacity(0.5),
              offset: const Offset(0, 2),
              blurRadius: 4,
            )
          ]
      ),
      child: Row(
        children: [
          // --- Back Button ---
          _AnimatedPressButton(
            onTap: onBackPressed,
            baseColor: headerGreenColor, // Match parent background
            shadowColor: headerGreenDarkerColor, // Use darker green for depth
            borderRadius: borderRadius - 4, // Slightly smaller radius
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: const Icon(Icons.arrow_back_rounded, color: headerTextColor, size: 26),
          ),
          const SizedBox(width: 8),

          // --- Title Text ---
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: headerTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // --- Right Button (Select Subject / Guidebook) ---
          _AnimatedPressButton(
            onTap: onRightButtonPressed,
            baseColor: headerGreenColor.withOpacity(0.9), // Slightly different shade?
            shadowColor: headerGreenDarkerColor,
            borderRadius: borderRadius - 4,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                // Icon to mimic Guidebook or represent subject selection
                Icon(Icons.menu_book_rounded, color: headerTextColor, size: 18),
                SizedBox(width: 6),
                Text(
                  // Change text based on functionality
                  "SUBJECTS", // Or "GUIDEBOOK"
                  style: TextStyle(
                    color: headerTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable Button with Push-Down Animation
class _AnimatedPressButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color baseColor;
  final Color shadowColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double pressDepth; // How much the button appears to move down

  const _AnimatedPressButton({
    required this.onTap,
    required this.child,
    required this.baseColor,
    required this.shadowColor,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.pressDepth = 3.0, // Default push depth
  });

  @override
  State<_AnimatedPressButton> createState() => _AnimatedPressButtonState();
}

class _AnimatedPressButtonState extends State<_AnimatedPressButton> {
  bool _isPressed = false;
  final Duration _pressDuration = const Duration(milliseconds: 80);

  @override
  Widget build(BuildContext context) {
    final double currentShadowOffsetY = _isPressed ? widget.pressDepth * 0.4 : widget.pressDepth; // Shadow comes up slightly when pressed
    final double currentTranslationY = _isPressed ? widget.pressDepth * 0.6 : 0; // Content moves down

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) { if (mounted) setState(() => _isPressed = true); },
      onTapUp: (_) { if (mounted) Future.delayed(_pressDuration, () { if (mounted) setState(() => _isPressed = false); }); },
      onTapCancel: () { if (mounted) setState(() => _isPressed = false); },
      child: SizedBox(
        // Use SizedBox to define the touch area including potential shadow space
        // Adding pressDepth to height ensures space for shadow doesn't get clipped
        height: widget.padding.vertical + 40, // Approximate height based on padding & typical text/icon
        // Width is determined by child + padding
        child: AnimatedSlide( // Animate the content's vertical position
          offset: Offset(0, currentTranslationY / (widget.padding.vertical + 40)), // Relative offset
          duration: _pressDuration,
          curve: Curves.easeOut,
          child: Stack( // Layer shadow and content
            alignment: Alignment.topCenter, // Align to top for vertical positioning
            children: [
              // --- Shadow Layer ---
              Container(
                // Margin controls the shadow offset animation implicitly
                margin: EdgeInsets.only(top: currentShadowOffsetY),
                padding: widget.padding, // Ensure shadow matches button size
                decoration: BoxDecoration(
                  color: widget.shadowColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: _isPressed ? pressedShadow : null, // Optional extra shadow on press
                ),
                // Use Opacity to make shadow invisible but maintain size for layout
                child: Opacity(opacity: 0, child: widget.child),
              ),
              // --- Content Layer ---
              Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.baseColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(color: widget.shadowColor.withOpacity(0.5), width: 0.5), // Subtle border
                ),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Widget responsible for laying out the scrollable path of lesson nodes AND map decorations.
class _LessonPath extends StatelessWidget {
  // (Properties remain the same)
  final List<String> lessons;
  final Map<String, int> lessonStates;
  final Map<String, GlobalKey> lessonKeys;
  final ScrollController scrollController;
  final void Function(BuildContext, String) onNavigate;

  const _LessonPath({ /* constructor remains the same */
    required this.lessons, required this.lessonStates, required this.lessonKeys,
    required this.scrollController, required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    // (Build method remains the same)
    return SingleChildScrollView( controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column( children: _buildPathWithDecorations(context)),
    );
  }

  // (Helper method _buildPathWithDecorations remains the same)
  List<Widget> _buildPathWithDecorations(BuildContext context) {
    List<Widget> pathItems = []; final random = math.Random();
    pathItems.add(const _GrassPatch(height: 50)); pathItems.add(const SizedBox(height: 20));
    for (int index = 0; index < lessons.length; index++) {
      final lessonName = lessons[index]; final int state = lessonStates[lessonName] ?? 0;
      final bool isLocked = state == 0; final bool isCompleted = state == 2;
      final bool isCurrent = state == 1; final bool isLastLesson = index == lessons.length - 1;
      final layout = _getLayoutForIndex(index);
      pathItems.add( Padding( padding: layout.padding, child: Align( alignment: layout.alignment,
        child: _LessonNode( key: lessonKeys[lessonName], lessonName: lessonName, isLocked: isLocked,
          isCompleted: isCompleted, isCurrent: isCurrent, isLastLesson: isLastLesson,
          onTap: isLocked ? null : () => onNavigate(context, lessonName), ), ), ), );
      bool addDecoration = (index % 3 == 1) || (isLastLesson && index > 0);
      if (addDecoration && index < lessons.length - 1) {
        pathItems.add( _MapDecoration.random( random: random,
          preferredAlignment: _getLayoutForIndex(index + 1).alignment == Alignment.centerLeft ? DecorationAlignment.right : DecorationAlignment.left, ) );
      }
    }
    pathItems.add(const SizedBox(height: 30)); pathItems.add(const _GrassPatch(height: 80));
    return pathItems;
  }

  // (Helper method _getLayoutForIndex remains the same)
  ({Alignment alignment, EdgeInsets padding}) _getLayoutForIndex(int index) {
    const double horizontalOffset = 30.0; const double verticalSpacing = 45.0;
    EdgeInsets padding; Alignment alignment = Alignment.center; int patternIndex = index % 4;
    switch (patternIndex) { case 0: padding = EdgeInsets.only(left: horizontalOffset, bottom: verticalSpacing); break;
      case 1: padding = EdgeInsets.only(bottom: verticalSpacing); break; case 2: padding = EdgeInsets.only(right: horizontalOffset, bottom: verticalSpacing); break;
      case 3: default: padding = EdgeInsets.only(bottom: verticalSpacing); break; }
    return (alignment: alignment, padding: padding);
  }
}


/// Widget representing a single lesson node with push-down press animation.
class _LessonNode extends StatefulWidget {
  // (Properties remain the same)
  final String lessonName; final bool isLocked; final bool isCompleted;
  final bool isCurrent; final bool isLastLesson; final VoidCallback? onTap;
  const _LessonNode({ super.key, required this.lessonName, required this.isLocked, required this.isCompleted,
    required this.isCurrent, required this.isLastLesson, this.onTap, });
  @override
  State<_LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<_LessonNode> {
  // (State and build logic remain the same as previous version)
  bool _isPressed = false; final Duration _pressDuration = const Duration(milliseconds: 80);
  @override
  Widget build(BuildContext context) { final appearance = _getNodeAppearance(); final bool showStartLabel = widget.isCurrent;
  const double nodeSize = 75.0; const double shadowHeightFactor = 0.12; final double baseShadowVerticalOffset = nodeSize * shadowHeightFactor;
  final double pressedShadowVerticalOffset = baseShadowVerticalOffset * 0.5; final double currentShadowVerticalOffset = _isPressed ? pressedShadowVerticalOffset : baseShadowVerticalOffset;
  final double pressTranslationY = baseShadowVerticalOffset - pressedShadowVerticalOffset; const double labelHeight = 38.0; const double labelBottomMargin = 8.0;
  final double totalHeight = nodeSize + baseShadowVerticalOffset + (showStartLabel ? (labelHeight + labelBottomMargin) : 0); const double totalWidth = nodeSize + 30;
  return GestureDetector( onTap: widget.onTap, onTapDown: (_) { if (widget.onTap != null && mounted) setState(() => _isPressed = true); }, onTapUp: (_) { if (widget.onTap != null && mounted) Future.delayed(_pressDuration, () { if (mounted) setState(() => _isPressed = false); }); }, onTapCancel: () { if (widget.onTap != null && mounted) setState(() => _isPressed = false); },
    child: SizedBox( width: totalWidth, height: totalHeight,
      child: AnimatedSlide( offset: Offset(0, _isPressed ? pressTranslationY / totalHeight : 0), duration: _pressDuration, curve: Curves.easeOut,
        child: Stack( alignment: Alignment.center, clipBehavior: Clip.none, children: [
          if (showStartLabel) Positioned(top: 0, child: _buildStartLabel()),
          Positioned( top: showStartLabel ? (labelHeight + labelBottomMargin) : 0, left: (totalWidth - nodeSize) / 2,
            child: _buildNodeBody(nodeSize, currentShadowVerticalOffset, appearance, _isPressed), ), ], ), ), ), ); }
  ({Color node, Color shadow, Color icon, IconData iconData}) _getNodeAppearance() { if (widget.isLastLesson && !widget.isCurrent) { return (node: lessonCompletedColor, shadow: lessonCompletedShadowColor, icon: trophyColor, iconData: Icons.emoji_events_rounded); } if (widget.isLocked) { return (node: lessonLockedColor, shadow: lessonLockedShadowColor, icon: lockedNodeIconColor, iconData: Icons.lock_rounded); } else if (widget.isCompleted) { return (node: lessonCompletedColor, shadow: lessonCompletedShadowColor, icon: nodeIconColor, iconData: Icons.check_rounded); } else { return (node: lessonReadyColor, shadow: lessonReadyShadowColor, icon: nodeIconColor, iconData: Icons.play_arrow_rounded); } }
  Widget _buildStartLabel() { return Container( padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), decoration: BoxDecoration( color: lessonLabelBgColor, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: shadowColor, offset: Offset(2.0, 2.0), blurRadius: 0.0, spreadRadius: 0.0)], border: Border.all(color: primaryTextColor.withOpacity(0.5), width: 1.5) ), child: const Text('START', style: TextStyle(color: lessonLabelTextColor, fontWeight: FontWeight.w800, fontSize: 15)), ); }
  Widget _buildNodeBody(double nodeSize, double currentShadowOffset, ({Color node, Color shadow, Color icon, IconData iconData}) appearance, bool isPressed) { return SizedBox( width: nodeSize, height: nodeSize + currentShadowOffset, child: Stack( alignment: Alignment.topCenter, children: [ Container( width: nodeSize, height: nodeSize, margin: EdgeInsets.only(top: currentShadowOffset), decoration: BoxDecoration( color: appearance.shadow, shape: BoxShape.circle, boxShadow: isPressed ? pressedShadow : null ) ), Container( width: nodeSize, height: nodeSize, decoration: BoxDecoration( color: appearance.node, shape: BoxShape.circle, border: Border.all(color: primaryTextColor.withOpacity(0.1), width: 1.0)), child: Icon(appearance.iconData, color: appearance.icon, size: nodeSize * 0.55) ), if (!widget.isLocked) Container( width: nodeSize, height: nodeSize, decoration: BoxDecoration( shape: BoxShape.circle, gradient: RadialGradient( center: const Alignment(-0.7, -0.8), radius: 1.0, colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.0)], stops: const [0.0, 0.8], ), ), ), ], ), ); }
}


// --- Map Decoration Widgets --- (Remain the same)
enum DecorationType { tree, bush, xMark }
enum DecorationAlignment { left, right }
class _MapDecoration extends StatelessWidget { final DecorationType type; final DecorationAlignment alignment; const _MapDecoration({required this.type, required this.alignment}); factory _MapDecoration.random({required math.Random random, required DecorationAlignment preferredAlignment}) { int typeRoll = random.nextInt(5); DecorationType chosenType; if (typeRoll < 3) chosenType = DecorationType.tree; else if (typeRoll < 4) chosenType = DecorationType.bush; else chosenType = DecorationType.xMark; DecorationAlignment chosenAlignment = preferredAlignment; return _MapDecoration(type: chosenType, alignment: chosenAlignment); } @override Widget build(BuildContext context) { Widget decorationWidget; double horizontalPadding = 60.0; switch (type) { case DecorationType.tree: decorationWidget = _buildTree(); break; case DecorationType.bush: decorationWidget = _buildBush(); break; case DecorationType.xMark: decorationWidget = _buildXMark(); horizontalPadding = 40.0; break; } EdgeInsets padding = EdgeInsets.only( left: alignment == DecorationAlignment.right ? horizontalPadding : 0, right: alignment == DecorationAlignment.left ? horizontalPadding : 0, bottom: 20, top: 5, ); return Padding( padding: padding, child: Align( alignment: alignment == DecorationAlignment.left ? Alignment.centerLeft : Alignment.centerRight, child: decorationWidget, ), ); } Widget _buildTree() { return SizedBox( width: 40, height: 60, child: Stack( alignment: Alignment.bottomCenter, children: [ Container(width: 10, height: 25, color: treeTrunkColor), Positioned(top: 0, child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: treeLeavesColor, shape: BoxShape.circle))), Positioned(top: 10, left: 0, child: Container(width: 25, height: 25, decoration: BoxDecoration(color: treeLeavesColor.withOpacity(0.8), shape: BoxShape.circle))), Positioned(top: 10, right: 0, child: Container(width: 25, height: 25, decoration: BoxDecoration(color: treeLeavesColor.withOpacity(0.8), shape: BoxShape.circle))), ], ), ); } Widget _buildBush() { return Container( width: 35, height: 25, decoration: BoxDecoration( color: treeLeavesColor, borderRadius: BorderRadius.circular(12), ), ); } Widget _buildXMark() { return Icon( Icons.close_rounded, color: xMarkColor, size: 30, shadows: [ BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3, offset: const Offset(1,1)) ], ); } }
class _GrassPatch extends StatelessWidget { final double height; const _GrassPatch({this.height = 60}); @override Widget build(BuildContext context) { return Container( height: height, decoration: BoxDecoration( gradient: LinearGradient( begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [ grassDarkerColor, grassColor, grassColor.withOpacity(0.7)], stops: const [0.0, 0.6, 1.0], ), ), ); } }
// --- End Map Decoration Widgets ---